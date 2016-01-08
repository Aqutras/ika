if Rails.env == 'test'
  require 'carrierwave'
end
require 'carrierwave/serialization'
require 'carrierwave/base64uploader'

module Ika
  extend ActiveSupport::Concern

  module ClassMethods
    include ::CarrierWave::Base64Uploader

    def ika_import(json_or_array, options = {})
      if json_or_array.is_a?(Array)
        objects = json_or_array
      else
        objects = JSON.parse(json_or_array)
        objects = [objects] unless objects.is_a?(Array)
      end

      ActiveRecord::Base.transaction do
        if options && options[:sync]
          remove_target_ids = all.pluck(:id)
        else
          remove_target_ids = []
        end
        objects.each do |object|
          record_exists = false
          if exists?(id: object['id'].to_i)
            record_exists = true
            exist_object = where(id: object['id'].to_i).first
          end

          object_params = {}
          object.keys.each do |key|
            if object[key].is_a?(Array)
              reflections[key].klass.import(object[key])
            else
              if new.try(key.to_sym).class.superclass == CarrierWave::Uploader::Base
                need_update = true
                obj_url = object[key]['url'] || object[key][:url]
                obj_md5 = object[key]['md5'] || object[key][:md5]
                obj_data = object[key]['data'] || object[key][:data]
                obj_name = object[key]['name'] || object[key][:name]
                if obj_url && File.exist?('public' + obj_url)
                  md5 = Digest::MD5.file('public' + obj_url)
                  need_update = false if md5 == obj_md5 && record_exists && obj_name == Pathname(exist_object.try(key.to_sym).to_s).basename.to_s
                end
                if obj_url && need_update
                  object_params[key] = base64_conversion(obj_data, obj_name)
                elsif obj_url.blank?
                  object_params[('remove_' + key).to_sym] = true
                end
              else
                object_params[key] = object[key]
              end
            end
          end
          if record_exists
            exist_object.attributes = object_params
            exist_object.save!(validate: false)
          else
            new(object_params).save!(validate: false)
          end
          remove_target_ids -= [object['id'].to_i]
        end
        where(id: remove_target_ids).destroy_all
      end
    end

    def import(json_or_array, options = {})
      ika_import(json_or_array, options)
    end

    def ika_export(options = {}, object = nil)
      CarrierWave::Uploader::Base.json_with_raw_data = true
      all_symbol = true
      options[:include] ||= []
      options[:include] = [options[:include]] unless options[:include].is_a?(Array)
      objects = self.includes(options[:include]) unless objects
      options[:include].each do |opt|
        all_symbol = false unless opt.is_a?(Symbol)
      end

      if all_symbol
        json = objects.to_json(include: options[:include])
        CarrierWave::Uploader::Base.json_with_raw_data = false
        return json
      end

      whole_obj_arr = []
      objects.each do |object|
        obj_arr = {}
        options[:include].each do |relation|
          if relation.is_a?(::Hash)
            relation.keys.each do |property|
              obj_arr[property] = JSON.parse(object.try(property).export({include: relation[property]}, object.try(property)))
            end
          elsif relation.is_a?(Symbol)
            obj_arr[relation] = JSON.parse(object.try(:relation).to_json(include: relation))
          end
        end
        whole_obj_arr.push(obj_arr)
      end
      CarrierWave::Uploader::Base.json_with_raw_data = false
      JSON.generate(whole_obj_arr)
    end

    def export(options = {}, object = nil)
      ika_export(options, object)
    end
  end

  def ika_export(options = {}, object = nil)
    CarrierWave::Uploader::Base.json_with_raw_data = true
    objects ||= self
    all_symbol = true
    options[:include] ||= []
    options[:include] = [options[:include]] unless options[:include].is_a?(Array)
    options[:include].each do |opt|
      all_symbol = false unless opt.is_a?(Symbol)
    end

    if all_symbol
      json = objects.to_json(include: options[:include])
      CarrierWave::Uploader::Base.json_with_raw_data = false
      return json
    end

    obj_hash = JSON.parse objects.to_json
    options[:include].each do |relation|
      if relation.is_a?(::Hash)
        relation.keys.each do |property|
          obj_hash[property] = JSON.parse(objects.try(property).includes(relation[property]).export({include: relation[property]}, objects.try(property)))
        end
      elsif relation.is_a?(Symbol)
        obj_hash[relation] = JSON.parse(objects.try(relation).to_json)
      end
    end
    CarrierWave::Uploader::Base.json_with_raw_data = false
    JSON.generate(obj_hash)
  end

  def export(options = {}, object = nil)
    ika_export(options, object)
  end
end

ActiveRecord::Base.send(:include, Ika)

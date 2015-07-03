require 'carrierwave/serialization'
require 'carrierwave/base64uploader'

module Ika
  extend ActiveSupport::Concern

  module ClassMethods
    include ::CarrierWave::Base64Uploader

    def import(json_or_array)
      if json_or_array.is_a?(Array)
        objects = json_or_array
      else
        objects = JSON.parse(json_or_array)
        objects = [objects] unless objects.is_a?(Array)
      end

      ActiveRecord::Base.transaction do
        objects.each do |object|
          record_exists = true if exists?(id: object['id'].to_i)

          object_params = {}
          object.keys.each do |key|
            if object[key].is_a?(Array)
              reflections[key].klass.import(object[key])
            else
              if new.try(key.to_sym).class.superclass == CarrierWave::Uploader::Base
                need_update = true
                if File.exist?('public' + object[key]['url'])
                  md5 = Digest::MD5.file('public' + object[key]['url'])
                  need_update = false if md5 == object[key]['md5'] && record_exists == true
                end
                object_params[key] = base64_conversion(object[key]['data'], object[key]['name']) if need_update
              else
                object_params[key] = object[key]
              end
            end
          end
          if record_exists
            where(id: object['id'].to_i).first.update(object_params)
          else
            create(object_params)
          end
        end
      end
    end

    def export(options = {}, objects = nil)
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
  end

  def export(options = {}, object = nil)
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
end

ActiveRecord::Base.send(:include, Ika)

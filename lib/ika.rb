module Ika
  extend ActiveSupport::Concern

  class ::Hash
    def max_depth
      max_depth = 1
      depth_func = ->(hsh, cur_depth) do
        max_depth = cur_depth if cur_depth > max_depth
        hsh["children"].to_a.each{|h| depth_func.call(h, cur_depth+1)}
        max_depth
      end
      depth_func.call(self, 0)
    end
  end

  module ClassMethods
    def export(options = {}, objects = nil)
      all_symbol = true
      options[:include] ||= []
      options[:include] = [options[:include]] unless options[:include].is_a?(Array)
      objects = self.includes(options[:include]) unless objects
      options[:include].each do |opt|
        all_symbol = false unless opt.is_a?(Symbol)
      end

      return objects.to_json(include: options[:include]) if all_symbol

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
      JSON.generate(whole_obj_arr)
    end
  end

  def export(options = {}, object = nil)
    objects ||= self
    all_symbol = true
    options[:include] ||= []
    options[:include] = [options[:include]] unless options[:include].is_a?(Array)
    options[:include].each do |opt|
      all_symbol = false unless opt.is_a?(Symbol)
    end

    return objects.to_json(include: options[:include]) if all_symbol

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
    JSON.generate(obj_hash)
  end
end

ActiveRecord::Base.send(:include, Ika)

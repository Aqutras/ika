module Ika
  extend ActiveSupport::Concern

  def export(options = self.class.reflections.keys)
    to_json(include: options)
  end

  module ClassMethods
    def export(options = reflections.keys)
      includes(options).to_json(include: options)
    end
  end
end

ActiveRecord::Base.send(:include, Ika)

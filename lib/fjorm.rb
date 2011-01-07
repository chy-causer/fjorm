require 'fjorm/field'

module Fjorm
  class Form
    include Rack::Utils

    attr_reader :fields, :error_list
    def initialize(params=nil)
      @input_received = params ? true : false
      @fields = self.class.class_eval do
        instance_variable_get(:'@fields').map{|field|
          case field.size
          when 1
            field[0].new
          when 2
            field[0].new(field[1])
          when 3
            field[0].new(field[1], field[2])
          end
        }
      end
      if @input_received
        @fields.each do |field|
          if field.value.blank? and params[field.name]
            field.value = escape_html params[field.name] 
          end
        end
      end
      add_field_methods 
    end

    def errors
      if @input_received
        @fields.select(&:errors?).map(&:onerror)
      else
        []
      end
    end

    def valid?
      not @fields.any?{|field| field.errors?}
    end

    def as_paragraph()
      @fields.map{|field|
        field.to_p
      }.join("\n")
    end

    private

    def add_field_methods
      @fields.each do |field|
        class_eval{define_method(field.name){field}}
      end
    end
  end
end

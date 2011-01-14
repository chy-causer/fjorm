module Fjorm
  class Field
    include Rack::Utils

    attr_reader :name, :regexp, :title, :onerror, :type 
    attr_accessor :value
    @defaults = {:type=>'text',  
              :onerror =>'Error', :regexp=>/.*/, :value=>''}
    @@base_defaults = @defaults.dup

    def initialize(name, kwargs={})
      @name = name.to_sym
      base_defaults = @@base_defaults
      added_defaults = self.class.class_eval do 
        instance_variable_get '@defaults'.to_sym
      end
      @defaults = base_defaults.merge added_defaults
      options = @defaults.merge kwargs
      @type = options[:type]
      @value = escape_html options[:value]
      @regexp = options[:regexp]
      @title = options[:title] || @name.to_s.titleize
      @onerror = options[:onerror]
      @html_id = options[:html_id] || @name
      @label_tag = options[:label_tag] || "<label for='#{@name}'> #{@title} </label>"
    end

    def errors?
      return @value.match(@regexp) == nil
    end

    def to_p(error = false)
      "<p> #{@label_tag} <input type='#{@type}' id='#{@html_id}' name='#{@name}' value='#{@value}' /></p>"
    end

    def to_tr(error = false)
      "<tr><td> #{@label_tag}</td><td>#{@input_tag}</td></tr>"
    end
  end

  class TextField <Field
    @defaults = {:type=>'text'}
  end

  class EmailField <TextField
    @defaults = {:type=>'email', 
      :regexp => /^[^@]+@[^\.]+\..+$/}
  end

  class SubmitField <Field
    @defaults = {:type=>'submit',
      :name=>:submit, :value=>'Submit',
      :label_tag => ''
    }

    def initialize(kwargs={})
      super 'submit'
    end
  end

  class TextAreaField <Field
    @defaults = {}
    def to_p
      return <<EOF
<p> #{@label_tag} </p>
<p>
  <textarea id='#{@html_id}' name='#{@name}'>#{@value}</textarea>
</p>
EOF
    end
  end
end

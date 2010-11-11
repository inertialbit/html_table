module HtmlTable
  module Helpers
    def html_table_for(collection, options={})
      table_body_options = options.delete(:table_body_options) || {}
      table_options = options.delete(:table_options) || {}
    
      @formatter = Formatter.new(collection, options)
    
      table_class = @formatter.embedded_class_name
      table_options[:class] = ['html_table',table_class,table_options[:class]].compact.join(" ")

      content_tag(:table, table_options) do
        table_header + table_body(collection, table_body_options)
      end
    end

    def table_body(collection, options={})
      return unless defined?(@formatter)
      content_tag(:tbody) do
        collection.map do |obj|
          data_row(obj) + action_row(obj, options)
        end.join('')
      end
    end
  
    def action_row(obj, options={})
      return if options[:exclude_management]
    
      management_link_methods = options[:management_link_methods] || []
    
      content_tag(:tr, {
        :class => 'html_table actions'
      }) do
        content_tag(:td, nil) +
        content_tag(:td, {
          :colspan => @formatter.columns.size - 1
        }) do
          management_link_methods.map do |m, opts|
            next if opts[:blacklisted] || opts[:options][:method] == 'delete'
            management_link_to(m, opts)
          end.compact.sort{|s1, s2| s1[0] <=> s2[0]}.join(" ") + " " +
          
          # todo do this w/out iterating over all members
          management_link_methods.map do |m, opts|
            next if opts[:options][:method] != 'delete'
            management_link_to(m, opts)
          end.compact.join(" ")
        end
      end
    end
    
    def management_link_to(path_helper_name, options={})
      text = options[:text] ? options[:text] : m.to_s.gsub(/_(path|url)/, '')
      text = text.humanize.downcase
      path = options[:use_obj] ? send(m, obj) : send(m)
      link_to(text, path, options[:options])
    end
  
    def data_row(obj)
      content_tag(:tr, {
        :class => 'html_table data'
      }) do
        @formatter.columns.map do |column|
          opts = @formatter.column_options[column]
          collection_or_content = obj.send column
          content_tag(:td, opts) do
            unless collection_or_content.kind_of?(Array)
              collection_or_content
            else
              format_collection(collection_or_content)
            end
          end
        end.join('')
      end
    end

    def table_header
      return unless defined?(@formatter)
      content_tag(:thead) do
        content_tag(:tr) do
          @formatter.columns.map do |column|
            opts = @formatter.column_options[column]
            content_tag(:th, opts) do
              @formatter.format_column(opts[:column_name] || column)
            end
          end.join('')
        end
      end
    end
  
    def format_collection(collection=[])
      # todo support custom display of collections
      unless collection.empty? || collection.first.respond_to?(:name)
        raise ArgumentError, "Collection objects must respond to :name"
      end
      s = collection.compact.map do |item|
        link_to(item.name, polymorphic_path(item))
      end.join("; ")
      s = s.blank? ? 'None' : s
      s
    end
  end
end

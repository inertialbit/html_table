module HtmlTable
  class Formatter
    attr_reader :embedded_class_name, :columns, :column_options, :column_map
  
    def initialize(collection, options={})
      @actual_class_name = collection.first.class
    
      unless @actual_class_name.ancestors.include?(ActiveRecord::Base)
        raise "HtmlTable::Formatter collections must be active record objects, sorry."
      end
      # build blacklist    
      @blacklist = (options.delete(:blacklist) || []).compact.map{|n| n.parameterize("_")}
      @blacklist += @actual_class_name.protected_attributes.entries
    
      @embedded_class_name = @actual_class_name.to_s.tableize
    
      @column_map = options.delete(:column_map) || {}
    
      # build content column hash(es)
      @column_options = {}
      @actual_class_name.reflections.each do |k,v|
        next if blacklisted?(k)
        merge_new_column_options(k)
      end
      @actual_class_name.column_names.each do |c|
        next if blacklisted?(c)
        merge_new_column_options(c)
      end
    
      # todo need to allow for additional custom columns at some point
      # maybe there's a better way...
      # @actual_class_name.custom_columns.each do |column_name|
      #   next if blacklisted?(column_name)
      #   merge_new_column_options(column_name)
      # end
    
      @columns = @column_options.keys #.sort!
    end
  
    def merge_new_column_options(c)
      options = column_map[c.to_sym] || {}
      unless options.empty?
        col = options[:method] || c
        col_class = [col, options[:class]].compact.join(" ")
      else
        col = c
        col_class = c
      end
      @column_options.merge!({
        col.to_s => {
          :class => col_class
        }.merge!(options)
      })
    end
  
    def format_column(column_name)
      column_name.humanize.titleize
    end
  
    def blacklisted?(column_name)
      @blacklist.include?(column_name.to_s)
    end
  end
end

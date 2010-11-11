require 'html_table/formatter'
require 'html_table/helpers'

if defined?(ApplicationController)
  ApplicationController.send :helper, HtmlTable::Helpers
end

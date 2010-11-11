require 'spec_helper'
require 'acts_as_fu'

RSpec.configure do |config|
  config.include ActsAsFu
end
describe HtmlTable::Formatter do
  before(:each) do
    build_model :fake_object do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env.to_sym])
      string :name
      integer :parent_id
      
      belongs_to :parent, :class_name => FakeObject
      has_many :children, :class_name => FakeObject
    end
    @f1 = FakeObject.create!({:name => 'Fake One'})
    @f2 = FakeObject.create!({:name => 'Fake Two'})
    @f3 = FakeObject.create!({:name => 'Fake Three'})
    @f4 = FakeObject.create!({:name => 'Fake Four'})
    @options = {
      :blacklist => ['email'],
      :column_map  => {
        :name => {
          :column_name => 'Fake Object'
        }
      }
    }
    opts = @options.dup
    @formatter = HtmlTable::Formatter.new(FakeObject.all, opts)
  end
  
  it "stores @actual_class_name of first obj in collection" do
    @formatter.instance_variable_get("@actual_class_name").should eql FakeObject
  end
  it "raises an exception if FakeObject does not descend from ActiveRecord::Base" do
    lambda{HtmlTable::Formatter.new(['hello','bye'])}.should raise_error
  end
  it "adds protected_methods to the display blacklist" do
    @formatter.instance_variable_get('@blacklist').should include 'id'
  end
  it "adds values passed via :blacklist to the display blacklist" do
    @formatter.instance_variable_get('@blacklist').should include 'email'
  end
  it "stores @embedded_class_name of first obj in collection" do
    @formatter.instance_variable_get("@embedded_class_name").should eql 'fake_objects'
  end
  it "provides an attr_reader for :column_map" do
    @formatter.column_map.should eql @options[:column_map]
  end
  it "provides an attr_reader for :columns" do
    @formatter.columns.should include 'name'
  end
  it "includes association names in :columns" do
    @formatter.columns.should include 'parent'
    @formatter.columns.should include 'children'
  end
  it "provides an attr_reader for :column_options" do
    @formatter.column_options.should(include({
      'name' => {
        :class => 'name',
        :column_name => 'Fake Object'
      }
    }))
  end
end

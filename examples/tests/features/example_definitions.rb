# features/example_definitions.rb

require_relative '../example'

When /^I have Example with value "(.+?)"$/ do |value|
  @example = Example.new(value)
end

Then "it should be truthy" do
  @example.truthy?.should be_true
end

Given "it shouldn't be falsy" do
  @example.falsy?.should be_false
end

Then /it's value should be "(.+?)"$/ do |value|
  @example.value.should == value
end

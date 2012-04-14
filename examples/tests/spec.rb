require 'minitest/autorun'
require_relative 'example'

describe Example, "example with value" do
  let(:value) { "value" }
  subject { Example.new(value) }

  describe "when asked about the value" do
    it "should be the value" do
      subject.value.must_equal value
    end
  end

  it "should be truthy" do
    subject.truthy?.must_equal true
  end

  it "should not be falsy" do
    subject.falsy?.must_equal false
  end
end

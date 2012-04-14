require_relative 'example'

describe Example do
  let(:value) { "value " }
  subject { Example.new(value) }

  it "should have value of the value" do
    subject.value.should == value
  end

  its(:truthy?) { should be }
  its(:falsy?) { should_not be }
end

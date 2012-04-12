require 'spec_helper'

module Adventura
  class Klass < Entity
  end

  describe Collection do
    let(:collection) { Collection.new(Klass) }
    subject { collection }

    it "adds instance of given class" do
      instance = collection.add(:id)
      instance.should be_a(Klass)
    end

    it "adds passes id and attributes" do
      Klass.should_receive(:new).with(:id, label: "Label")
      collection.add(:id, label: "Label")
    end

    context "with limit" do
      before do
        collection.limit!(1)
      end

      it "should not add item over limit" do
        collection.add(:item).should be
        collection.count.should == 1

        collection.add(:another).should_not be
        collection.count.should == 1
      end

      it "should not set item over limit" do
        collection[:item] = Klass.new(:item)
        collection.count.should == 1

        collection.set(:another, Klass.new(:another)).should be false
        collection.count.should == 1
      end
    end

    context "with element with underscore" do
      before do
        collection.add(:long_dark_id)
        collection.add(:dark)
        collection.add(:dark_id)
      end

      it "looks up correct element" do
        collection.lookup("dark id").should == collection[:dark_id]
        collection.lookup("dark").should == collection[:dark]
      end
    end

    context "with element" do
      before { collection.add(:id) }
      let(:id) { collection[:id] }

      context "#to_a" do
        subject { collection.to_a }

        it { should == [ collection[:id] ] }
      end

      it "should give element by id or itself" do
        collection[:id].should == id
        collection[id].should == id
      end
    end

    context "with element with label" do
      before { collection.add(:knife, label: 'old army knife') }
      let(:knife) { collection[:knife] }

      it "should lookup element by label" do
        collection.lookup('knife').should == knife
        collection.lookup('old army knife').should == knife
      end

      it "should find element" do
        collection.find('knife').should == knife
        collection.lookup('old army knife').should == knife
      end
    end

    context 'with element with match' do
      before do
        collection.add(:knife, matcher: /ife/)
        collection.add(:wife, matcher: /wife/)
        collection.add(:callable, matcher: lambda { |object| object == collection[:callable]})
      end
      let(:knife) { collection[:knife] }
      let(:wife)  { collection[:wife] }
      let(:callable)  { collection[:callable] }

      it "should match string" do
        collection.match("knife").should == [knife]
        collection.match("wife").should include(knife, wife)
      end

      it "should match callable object" do
        collection.match(callable).should == [callable]
      end
    end

    context "with two elements" do
      before do
        collection.add(:id)
        collection.add(:another, attribute: :value)
      end

      its(:count) { should == 2 }
      context "searched element" do
        subject { collection.search{|el| el.attribute == :value } }
        it { should have(1).item }
        its(:first) { should == collection[:another] }
      end
    end

  end
end

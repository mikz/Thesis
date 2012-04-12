require 'spec_helper'

module Adventura
  describe Route do
    let(:route) { Route.new(:rocky_road, direction: :east, destination: :town) }
    subject { route }

    it { route.goes_to?(:town).should be_true }
    it { route.goes_to?(:lake).should be_false }

    it { route.goes?(:east).should be_true }
    it { route.goes?(:west).should be_false }

    context "defined with shortcuts" do
      let(:route) { Route.new(:short_road, dir: :west, dest: :city) }
      its(:destination) { should == :city }
      its(:direction) { should == :west }
    end

    context "defined without attributes" do
      let(:route) { Route.new(:left) }
      its(:destination) { should == :left }
      its(:direction) { should == nil }
      its(:dest) { should == :left }
      its(:dir) { should == nil }
    end
  end
end

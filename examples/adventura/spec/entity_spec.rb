require 'spec_helper'

module Adventura
  describe Entity do
    context "two entities" do
      let(:first) { Entity.new(:first) }
      let(:second) { Entity.new(:secon) }

      it { first.should_not === second }
      it { second.should_not === first }
      it { first.should_not == second }
      it { second.should_not == first }

      context "with same ids" do
        let(:second) { Entity.new(:first) }

        it { first.should === second }
        it { second.should === first }
        it { first == second }
        it { second == first }
      end
    end

    context "entity with name with underscores" do
      subject { Entity.new(:long_name) }

      it { should_not =~ "long" }
      it { should_not =~ "name" }
      it { should =~ "long name" }
      it { should =~ :long_name }

    end

  end
end

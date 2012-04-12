require 'spec_helper'

module Adventura
  describe Room do
    context "cave has multiple routes to lake" do
      let(:cave) { Room.new(:cave) }
      let(:lake) { Room.new(:lake) }
      let(:routes) { cave.routes.to_a }

      before do
        cave.routes do
          add(:rocky_tunnel, direction: :west, destination: :lake)
          add(:under_water, direction: :down, destination: :lake)
        end
      end

      it "returns all routes to lake" do
        cave.routes_to(:lake).should =~ routes
      end

      it "returns all routes on west" do
        cave.routes_on(:west).should == [ cave.routes[:rocky_tunnel] ]
      end

      it "returns routes when string given" do
        cave.routes_to("lake").should =~ routes
      end

      it "returns routes when room passed" do
        cave.routes_to(lake).should =~ routes
      end

    end

  end
end

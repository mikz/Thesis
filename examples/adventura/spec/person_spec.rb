require 'spec_helper'

module Adventura
  describe Person do

    let(:knight) { Person.new(:knight) }
    subject { knight }

    its(:inventory) { should be_a(Collection) }

    context "two persons with callbacks" do
      let(:player) { Player.new('Player') }
      let(:item) { Item.new(:item) }
      let(:callbacks) { { :before => [], :after => []} }

      before do
        player.inventory << item
        player.stub(:world) { double('World', :callbacks => callbacks) }
        Adventura.world = player.world

        knight[:before] = { :take => ->(*args) { callbacks[:before] << args } }
        knight[:after]  = { :take => ->(*args) { callbacks[:after]  << args } }
      end

      it "should call callbacks" do
        player.give(item, knight)

        callbacks[:before].should == [ [item, player] ]
        callbacks[:after].should == [ [item, player] ]
      end
    end

  end
end

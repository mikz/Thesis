require 'spec_helper'

module Adventura
  describe Player do
    let(:interface) { double.as_null_object }
    let(:player) { Player.new "Player 1" }
    let(:world) { World.new(interface, player) }
    let(:transition) { world.send(:transition) }

    before do
      player.stub(:world) { world }
    end

    subject { player }

    its(:name){ should == "Player 1" }
    its(:inventory){ should be_empty }
    its(:position){ should be_nil }


    context 'with items' do
      let(:inventory) { player.inventory }
      let(:knife) { inventory[:knife] }
      let(:uzi)   { inventory[:uzi] }
      let(:action) { ->(item, other) { [item, other] } }
      let(:condition) { ->(item, other) { "passed" } }
      let(:usage) { ->(item, other) { other ? "used #{other.id}" : "used" } }

      before do
        inventory.add(:knife, action: action)
        inventory.add(:uzi, condition: condition, action: usage)
      end

      it "should call knife action" do
        world.player.use(knife).should == [knife, nil]
        world.player.use(knife, uzi).should == [knife, uzi]
      end

      it "should call uzi condition and usage" do
        world.player.use(uzi).should == "used"
        world.player.use(uzi, knife).should == "used knife"
      end
    end

    context 'in defined world' do
      let(:rooms) { world.rooms }
      let(:routes) { rooms[:start].routes }
      before do
        world.define do
          rooms.add(:start, label: "Start room") do
            routes.add(:right, dest: :right)
            routes.add(:left, dest: :left)
            routes.add(:bottom)
            routes.add(:strange_path, dest: :bottom)
          end
          rooms.add(:right, label: "Right room")
          rooms.add(:left,  label: "Left room")
          rooms.add(:bottom) do
            routes.add(:start)
            people do
              add(:dwarf, messages: { default: "Hi!", :bye => "Bye!" }, talk: ->(dwarf, player) { player.hi? ? :bye : :key })
            end
          end

          events do
            add('player teleports from left to right room') do
              watch(:room) { |room| room === :left }
              fire{ player.teleport(rooms[:right]) }
            end
          end
        end

        world.spin!
      end

      let(:dwarf) { rooms[:bottom].people[:dwarf] }

      its(:position) { should === :start }

      its "events are fired" do
        player.go_to rooms[:left], routes[:left], &transition
        player.position.should === :right
      end

      its "events are not fired" do
        player.go_to rooms[:bottom], routes[:bottom], &transition
        player.position.should === :bottom
      end

      it "follows route" do
        world.events.add("fake call") do
          watch(:route) { |route| route === :strange_path }
          fire { player.fake_call }
          on :leave
        end

        player.stub(:fake_call)
        player.should_receive(:fake_call)

        player.follow routes[:strange_path], &transition

        player.position.should === :bottom
      end

      it "can talk to people" do
        player.stub(:hi?){ false }
        player.talk(dwarf).should == "Hi!"
        player.stub(:hi?){ true }
        player.talk(dwarf).should == "Bye!"
      end

      it "fires events without block on every move" do
        world.events.add("everytime") do
          watch(:room)
          fire { player.fake_call }
          on :entry
        end

        player.stub(:fake_call)
        player.should_receive(:fake_call).twice

        player.follow routes[:strange_path], &transition
        player.follow rooms[:bottom].routes[:start], &transition
      end

    end

  end

end

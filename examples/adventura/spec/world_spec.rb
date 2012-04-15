# encoding: UTF-8
require 'spec_helper'

module Adventura
  describe World do
    let(:player) { Player.new("Player World") }
    let(:interface) { double("interface").as_null_object }
    let(:world) { World.new(interface, player, &definition) }

    before do
      player.stub(:world) { world }
    end

    subject { world }

    context "with two dark caves and routes between" do
      let(:definition) do
        lambda {
          rooms do
            add(:cave, darkness: 0.5) do
              routes.add(:tunnel, dir: :west, dest: :dark_cave)
              items.add(:another)
            end
            add(:dark_cave, darkness: 0.9) do
              routes.add(:dark_tunnel, dir: :east, dest: :cave)
            end
            add(:hidden_cave, darkness: 1.0) do
              items.add(:item)
            end
          end
        }
      end

      it { should have(3).rooms }

      context "entities" do
        let(:entities) { world.entities }
        let(:cave) { world.rooms[:cave] }
        subject { entities }

        before do
          player.start(cave)
        end

        it "should have all entities" do
          gem = player.inventory.add(:gem)
          entities.should be_a Adventura::Collection
          entities.to_a.should =~ [gem, cave.items[:another], cave.routes[:tunnel], cave]
        end
      end

      context 'when world stars in cave' do
        before do
          world.define do
            command(/^go to the (.+)$/, method: :go_to)
            command(/^go (\S+)$/, method: :go)
          end
          world.start = :cave
          world.spin!
        end

        it "handles 'go to the dark cave' command" do
          world.should_receive(:go_to).with('dark cave')
          world.process 'go to the dark cave'
        end

        it "handles go_to 'dark cave'" do
          world.go_to 'dark cave'
          player.position.should === :dark_cave
        end

        it "cannot go to non existent room" do
          world.go_to :non_existent
          player.position.should === :cave
        end

        it "cannot go to room without route" do
          world.go_to :hidden_cave
          player.position.should === :cave
        end

        it 'can follow direction' do
          world.go :west
          player.position.should === :dark_cave
        end

        it 'cant follow wrong direction' do
          world.go :east
          player.position.should === :cave
        end

      end

      context 'where cave' do
        let(:cave) { world.rooms[:cave] }
        let(:dark_cave) { world.rooms[:cave] }

        subject { cave }

        its(:darkness) { should == 0.5 }

        it "returns right routes on direction" do
          cave.routes_on(:west).should == [ cave.routes[:tunnel] ]
          cave.routes_on(:east).should be_empty
        end

        context 'route to dark cave' do
          subject { cave.routes_to(:dark_cave).first }
          its(:direction) { should == :west }
        end
      end
    end

    context "world with events" do

      let(:definition) do
        lambda {
          events do
            on(:start) do
              raise 'fired!'
            end
          end
        }
      end

      # it { should have(1).event }
      it "should fire start event" do
        expect { world.spin! }.to raise_error('fired!')
      end
    end
  end
end

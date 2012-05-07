require 'active_support/core_ext/hash/reverse_merge'
require 'set'

module Adventura
  class Player
    include Collection::DSL

    collection_of :items, :as => :inventory

    attr_reader :name, :route, :room

    attr_reader :abilities

    def initialize(name)
      @name = name
      @abilities = Set.new
    end

    def world
      Adventura.world
    end

    def position
      room or route
    end

    def walk_into room
      return unless world.condition(room, room, route)

      if route = self.route
        @route = nil
        transition(entity: :route, on: :leave, object: route, to: room)
      end
      if @room = room
        transition(entity: :room, on: :entry, object: room, from: route)
      else
        transition(entity: :dead_end, on: :entry, object: route)
      end
    end

    def walk_by route, room = nil
      return unless world.condition(route, route, room)

      if room = @room
        @room = nil
        transition(entity: :room, on: :leave, object: route, by: route)
      end
      @route = route
      transition(entity: :route, on: :entry, object: route, from: route)
    end

    def teleport(room)
      @room = room
    end

    def start(room, &block)
      @block = block
      transition(entity: :player, on: :create, object: self)
      @room = room
    end

    def go_to(room, route)
      walk_by(route, room) and walk_into(room)
    end

    def follow(route)
      go_to(world.rooms[route.destination], route)
    end

    def pick(item_name)
      items = position.items
      item = items.find(item_name) or return

      condition = item.pickable

      unless condition.nil?
        value = condition.respond_to?(:call) ? condition.call(self) : condition
        return value unless value
      end

      inventory.take(item, items) and item
    end

    def item(name)
      position.items.find(name) or inventory.find(name)
    end

    def use(item, other = nil)
      args = [item, other]
      result = world.condition(item, *args)
      item == result ? false : result
    end

    def talk(person)
      args = [person, self]
      person.message world.condition(person, *args)
    end

    def give(item, person)
      transition(entity: :item, on: :give, object: item, from: self, to: person)
      person.take(item, self)
    end

    private

    def transition(attributes)
      return unless @block
      attributes.reverse_merge! player: self
      transition = Transition.new(attributes)
      @block.call(transition)
    end

  end
end

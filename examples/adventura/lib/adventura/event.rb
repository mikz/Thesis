module Adventura
  class Event < Entity
    attr_reader :transition

    def match(transition)
      return unless transition.on == self.on
      @transition = transition if watching(transition.entity).any? { |watch| watch.matches?(transition.object) }
    end

    def watch(entity, &block)
      watchers.push Watcher.new(entity, &block)
    end

    def on(value = nil)
      @on ||= value || :entry
    end

    def fire &block
      @block = block
    end

    def fire!
      transition.world.instance_exec(transition, &@block)
    end

    private

    def watching(entity)
      watchers.select{ |watcher| entity === watcher.entity }
    end

    def watchers
      @watchers ||= []
    end

    class Watcher
      attr_reader :entity

      def initialize(entity, &block)
        @entity, @block = entity, block
      end

      def matches?(entity)
        not @block or @block[entity]
      end
    end
  end
end

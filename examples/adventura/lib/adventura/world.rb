module Adventura
  class World
    include Adventura::Collection::DSL

    # @attribute [r] items
    # @return [Collection<Item>]
    collection_of :items

    # @attribute [r] people
    # @return [Collection<Person>]
    collection_of :people

    # @attribute [r] rooms
    # @return [Collection<Room>]
    collection_of :rooms

    # @attribute [r] actions
    # @return [Collection<Action>]
    collection_of :actions

    # @attribute [r] events
    # @return [Collection<Event>]
    collection_of :events do
      def on(event, &block)
        add(event) do
          on event
          watch :world
          fire &block
        end
      end
    end

    attr_accessor :start
    # @return [Player]
    attr_reader :player

    attr_reader :interface

    # @param [Interface::Abstract] interface
    # @param [Player] player
    # @param [Proc] block
    # @yield the passed block in context of current instance
    def initialize(interface, player, &block)
      @interface = interface
      @player = player
      at_exit &method(:exit!).to_proc
      define(&block) if block
    end

    # @return [Collection<Room,Route,Item>]
    def entities
      current = player.position
      routes = current.routes
      # rooms = current.routes.map(&:dest).compact.map{ |name| self.rooms[name] }
      items = player.inventory | current.items

      Collection(Array(current) | routes | items) # | rooms # does not make sense to include rooms, they are too far away
    end

    # @return [void]
    def define(&block)
      instance_exec(&block)
    end

    # @return [void]
    def process string
      if command = commands.find { |cmd| cmd =~ string }
        command.execute(self, string)
      else
        interface.unknown_command string
      end
    end

    # @return [Array<Command>]
    def commands
      @commands ||= []
    end

    def start
      @start or :start
    end

    # @return [void]
    def spin!
      transition.call(Transition.new(entity: :world, on: :start, object: self, player: player))
      player.start(rooms[start], &transition)
    end

    # @return [void]
    def go_to room, route = nil
      room = rooms.lookup(room) or return interface.report_invalid_room
      unless route
        routes = player.position.routes_to(room)
        if routes.size > 1
          route = interface.ask_for_direction(routes, room)
        else
          route = routes.first or return interface.report_invalid_route
        end
      end

      player.go_to(room, route)
    end

    # @return [void]
    def go direction
      routes = player.position.routes_on(direction)
      return interface.ask_for_direction(routes) if routes.size > 1

      route = routes.first or return interface.report_invalid_route
      room = rooms[route.destination] or return interface.report_invalid_room

      player.go_to(room, route)
    end

    # @return [void]
    def follow route
      route = player.position.routes.find(route) or return interface.report_invalid_route

      player.follow(route)
    end

    # @return [void]
    def help
      cmds = commands.map { |command|
        next unless command.name
        [command.name, command.help]
      }.compact

      max = cmds.map{ |cmd| cmd.first.length }.max

      cmds.map! do |cmd|
        [cmd.first.ljust(max), cmd.last].compact.join(" # ")
      end

      interface.say cmds.join("\n")
    end

    # @return [void]
    def method_missing(method, *args)
      if action = actions.lookup(method)
        self.define_singleton_method(method, &action)
        self.send(method, *args)
      else
        super
      end
    end

    # @return [Array<String>]
    def possible_commands
      commands.map do |command|
        next if command.condition? and not instance_exec(&command.condition)
        command.name
      end.compact
    end

    # @return [Boolean]
    def condition(entity, *args)
      case

      when entity.condition? && entity.action?
        instance_exec(*args, &entity.condition) and instance_exec(*args, &entity.action)

      when entity.condition?
        result = instance_exec(*args, &entity.condition)
        if result and entity.success?
          instance_exec(*args, &entity.success)
        elsif not result and entity.failure?
          instance_exec(*args, &entity.failure)
        end
        result

      when entity.action?
        instance_exec(*args, &entity.action)

      else
        entity

      end
    end

    def win!
      transition.call(Transition.new(entity: :world, on: :win, object: self, player: player))
    end

    private
    def command matcher, options = {}
      commands << Command.new(matcher, options)
    end

    def transition
      lambda { |transition|
        transition.world = self
        events.match(transition).each(&:fire!)
      }
    end

    def exit!
      interface.say 'Exiting...'
    end

  end
end

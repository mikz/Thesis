module Adventura
  class World
    include Adventura::Collection::DSL

    collections_of :items, :people, :rooms, :actions
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
    attr_reader :player

    attr_reader :interface

    def initialize(interface, player, &block)
      @interface = interface
      @player = player
      at_exit &method(:exit!).to_proc
      define(&block) if block
      transition.call(Transition.new(entity: :world, on: :start, object: self, player: player))
    end

    def entities
      current = player.position
      routes = current.routes
      # rooms = current.routes.map(&:dest).compact.map{ |name| self.rooms[name] }
      items = player.inventory | current.items

      Collection(Array(current) | routes | items) # | rooms # does not make sense to include rooms, they are too far away
    end

    def define(&block)
      instance_exec(&block)
    end

    def process string
      command = commands.find { |cmd| cmd =~ string }
      if command
        command.execute(self, string)
      else
        interface.unknown_command string
      end
    end

    def commands
      @commands ||= []
    end

    def start
      @start or :start
    end

    def spin!
      player.start(rooms[start], &transition)
    end

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

    def go direction
      routes = player.position.routes_on(direction)
      return interface.ask_for_direction(routes) if routes.size > 1

      route = routes.first or return interface.report_invalid_route
      room = rooms[route.destination] or return interface.report_invalid_room

      player.go_to(room, route)
    end

    def follow route
      route = player.position.routes.find(route) or return interface.report_invalid_route

      player.follow(route)
    end

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

    def method_missing(method, *args)
      if action = actions.lookup(method)
        self.define_singleton_method(method, &action)
        self.send(method, *args)
      else
        super
      end
    end

    def possible_commands
      commands.map(&:name).compact
    end

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

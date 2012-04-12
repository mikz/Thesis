require "highline"
require "active_support/core_ext/module/delegation"

HighLine.track_eof = false

module Adventura
  module Interface
    class Shell
      attr_reader :stdin, :stdout, :stderr
      attr_reader :console
      def initialize(stdin = $stdin, stdout = $stdout, stderr = $stderr)
        @stdin, @stdout, @stderr = stdin, stdout, stderr
        @console = HighLine.new(stdin, stdout)
      end

      def unknown_command cmd
        say "Unknown command: #{cmd}"
      end

      def get_command possible_commands = nil
        ask "> " do |question|
          question.extend(Autocomplete)
          question.selection = possible_commands
        end
      end

      def ask_for_direction(routes, room = nil)
        header = "Which direction do you want to go?"
        header << " To get to the #{room}?" if room

        response = choose(*routes.map(&:to_s)) do |menu|
          menu.header = header
          menu.prompt = "Please select route by number or name."
        end

        routes.find {|route| route === response }
      end

      def choose(*choices)
        console.choose(choices) do |menu|
          menu.extend(Autocomplete)
          menu.select_by = :index_or_name
          yield(menu)
        end
      end

      def report_invalid_route
        say "Invalid route"
      end

      def report_invalid_room
        say "Invalid room"
      end

      private
      def self.highline_methods
        HighLine.instance_methods - HighLine.superclass.instance_methods
      end

      delegate *highline_methods, :to => :console
    end

    module Autocomplete
      def selection=(choices)
        define_singleton_method :selection do
          choices
        end
      end

      def readline
        $stdin.tty?
      end
    end

  end
end

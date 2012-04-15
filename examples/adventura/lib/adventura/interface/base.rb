module Adventura
  module Interface

    # @abstract Subclass and override methods to implement interface
    class Base

      def say; end
      def ask; end
      def unknown_command cmd; end
      def get_command possible_commands = nil; end
      def ask_for_direction(routes, room = nil); end
      def choose(*choices); end
      def report_invalid_route; end
      def report_invalid_room; end

    end
  end
end

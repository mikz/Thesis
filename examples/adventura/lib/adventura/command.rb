require 'ostruct'

module Adventura
  class Command < OpenStruct
    attr_reader :matcher

    delegate :match, :to => :matcher

    # @param [String, Regexp, #match] matcher
    # @param [Hash] options
    # @option options [String] help
    #
    def initialize(matcher, options = {})
      @matcher = matcher
      super(options)
      self.name ||= matcher if matcher.respond_to?(:to_str) && options[:help]
    end

    # @return [Boolean]
    def =~(command)
      super(command) or matcher.match(command)
    end

    def [](key)
      @table[key]
    end

    # @return [void]
    def execute(world, command)
      args = match(command).captures
      args = args.empty? ? self.args : args

      method = self[:method]

      if method.respond_to?(:call)
        world.instance_exec(*args, &method)
      else
        world.send method, *args
      end
    end
  end
end

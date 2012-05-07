require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/starts_ends_with'
require 'ostruct'

module Adventura
  class Entity < OpenStruct
    include Adventura::Collection::DSL

    attr_reader :id
    delegate :to_s, :to_sym, :to => :id

    # @param id
    # @param [Hash] attributes
    # @param [Proc] block
    # @yield the passed block in context of current instance
    def initialize(id, attributes = {}, &block)
      @id = id
      super(attributes)
      self.instance_exec(&block) if block
    end

    def [](key)
      @table[key]
    end

    def []=(key, val)
      @table[key] = val
    end
    alias :set :[]=

    def method_missing(method, *args)
      if method.to_s.ends_with?('?')
        attr = method.to_s.sub(/\?$/, '').to_sym
        if @table.keys.include?(attr)
          return @table[attr].present?
        end
      end

      super
    end

    def match(object)
      matcher and matcher.respond_to?(:call) ? matcher.call(object) : matcher.match(object)
    end

    def description
      super or format
    end

    def label
      super or id.to_s.humanize
    end

    # @return [Boolean]
    def ==(other)
      super and id == other.id
    end

    # @return [Boolean]
    def ===(other)
      other.to_sym === id
    end

    # @return [Boolean]
    def =~(other)
      self === other or self === other.to_s.gsub(/\s/,'_') or self.format == other
    end

    # @return [String]
    def to_str
      to_s
    end

    def format
      label or to_s
    end

    private

    def callback(action, *args)
      run_callback(:before, action, *args)
      ret = yield
      run_callback(:after, action, *args)
      ret
    end

    def run_callback(kind, action, *args)
      callback = self[kind].try(:[], action)
      if callback.respond_to?(:call)
        Adventura.world(*args, &callback)
      end
    end

  end
end

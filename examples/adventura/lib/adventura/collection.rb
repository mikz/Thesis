require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/try'
require 'active_support/inflections'

module Adventura

  class Collection
    include Enumerable

    # @param [Class] klass
    def initialize(klass = nil)
      @klass = klass
      @store = Hash.new
      @definitions = {}
      @limit = Float::INFINITY
    end

    def add id, attributes = {}, &block
      raise "#{@klass} with id #{id} already exists in this collection" if has_key?(id)

      return if hit_limit?

      self[id] = case @klass.instance_method(:initialize).arity
                 when 1
                   @klass.new(id, &block)
                 when -2
                   @klass.new(id, attributes, &block)
                 else
                   raise "unknown number of arguments"
                 end
    end

    # @param [Number]
    # @return [Number]
    def limit!(number)
      @limit = number
    end

    attr_accessor :limit

    # @return [Boolean]
    def hit_limit?
      count >= limit
    end

    # @overload define(key, value)
    #   @param key
    #   @param value
    # @overload define(key, &block)
    #   @param key
    #   @param block
    def define(key, value = nil, &block)
      @definitions[key] = value || block
    end

    # @return [Object, nil]
    def defined(key)
      @definitions[key]
    end

    # @return [Array]
    def match(object)
      values.select{ |value| value.match(object) }
    end

    # @param key [String, Symbol]
    # @return [Object, nil]
    def lookup(key)
      self[key] or find(key)
    end

    # @overload find(id)
    #   Finds object by id
    #   @param [String, Symbol, #match] id
    # @overload find(&block)
    #   @yield [element] object to match
    #   @yieldparam object one object of collection
    def find(id = nil, &block)
      block = ->(value) { value =~ id } if id
      values.find(&block)
    end

    # @yield [element]
    # @return [Array]
    def search
      @store.select{ |id, element| yield(element) }.values
    end

    # @return [Object, nil]
    def [](key)
      @store[key.to_sym]
    end

    def []=(key, value = key)
      if has_key?(key.to_sym)
        raise "Cannot replace existing value #{self[key]}"
      else
        return false if hit_limit?
        @store[key.to_sym] = value
      end
    end
    alias :set :[]=

    # @param key [String, Symbol, #to_sym]
    # @param collection [Collection, Array, #delete]
    def take(key, collection)
      set(key, collection.delete(key))
    end

    # @param key [String, Symbol, #to_sym]
    def delete(key)
      @store.delete(key.to_sym)
    end

    def format
      block = defined(:format) || -> { format }
      values.map{ |value| value.instance_exec(&block) }.join("\n")
    end

    # Add item to collection
    # @param item
    # @return item
    def <<(item)
      self[item] = item
    end

    # @method values
    # @return [Array]
    delegate :values, :to => :@store
    alias :to_a :values

    # @method empty?
    # @return [Boolean]
    delegate :empty?, :to => :@store

    # @method has_key?
    # @return [Boolean]
    delegate :has_key?, :to => :@store

    # @method count
    # @return [Integer]
    delegate :count, :to => :@store

    # @method each(&block)
    # @yield [element]
    # @return [Array] array
    delegate :each, :to => :values

    # @method |(other)
    # @param [Array] other other array
    # @return [Array]
    delegate :|, :to => :values

    # @method to_ary
    # @return [Array]
    delegate :to_ary, :to => :values

    private
    module DSL
      extend ActiveSupport::Concern

      included do
        class_attribute :collections, :instance_writer => false, :instance_reader => false
        class_attribute :collection_mapping, :instance_writer => false
        self.collections = []
        self.collection_mapping = {}
      end

      delegate :[], :to => :collections

      def collections
        @collections ||= Hash.new { |hash, key| hash[key] = Collection.new(collection_mapping[key]) if self.class.has_collection?(key) }
      end

      module ClassMethods
        def collections_of(*items)
          items.each { |item| collection_of(item) }
        end

        def collection_of(item, options = {}, &extension)
          reader = options[:as] || item
          collections << item
          collection_mapping[item] = "Adventura::#{item.to_s.singularize.capitalize}".constantize

          define_method(reader) do |&block|
            collections[item].instance_exec(&extension) if extension
            collections[item].instance_exec(&block) if block
            collections[item]
          end
        end

        def has_collection?(name)
          collections.include?(name)
        end

        def inherited(child)
          child.collections = self.collections.dup
          super if defined?(super)
        end
      end # ClassMethods

    end # DSL
  end

end

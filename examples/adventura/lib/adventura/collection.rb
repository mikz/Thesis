require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/try'
require 'active_support/inflections'

module Adventura

  class Collection < Hash
    def initialize(klass = nil)
      @klass = klass
      @definitions = {}
    end

    def add id, attributes = {}, &block
      raise "#{@klass} with id #{id} already exists in this collection" if has_key?(id)

      return if hit_limit?

      self[id] = item = @klass.new(id, attributes, &block)

      item
    end

    def limit!(number)
      @limit = number
    end

    def limit
      @limit or Float::INFINITY
    end

    def hit_limit?
      count >= limit
    end

    def define(key, value = nil, &block)
      @definitions[key] = value || block
    end

    def defined(key)
      @definitions[key]
    end

    def match(object)
      values.select{ |value| value.match(object) }
    end

    def lookup(key)
      self[key] or values.find{ |value| value =~ key }
    end

    def find(id = nil, &block)
      block = ->(value) { value =~ id } if id
      super(&block)
    end

    def to_a
      values
    end

    def search
      select{ |id, element| yield(element) }.values
    end

    def [](key)
      super(key.to_sym)
    end

    def []=(key, value = key)
      if has_key?(key.to_sym)
        raise "Cannot replace existing value #{self[key]}"
      else
        return false if hit_limit?
        super(key.to_sym, value)
      end
    end
    alias :set :[]=

    def take(key, collection)
      set(key, collection.delete(key))
    end

    def delete(key)
      super(key.to_sym)
    end

    def format
      block = defined(:format) || -> { format }
      values.map{ |value| value.instance_exec(&block) }.join("\n")
    end

    def <<(item)
      self[item] = item
    end

    delegate :each, :|, :to_ary, :to => :values # :&, :+,

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

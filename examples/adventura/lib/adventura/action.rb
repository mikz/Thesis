require 'active_support/core_ext/module/delegation'

module Adventura
  class Action
    attr_reader :id, :block
    delegate :to_s, :to_sym, :to => :id

    # @param id [String, Symbol, #to_sym]
    # @param block [Proc]
    def initialize id, &block
      @id = id
      @block = block
    end

    # @return [Proc]
    def to_proc
      @block # .dup.extend(Convertions).to_lambda
    end

    module Convertions
      def to_lambda
        obj = Object.new
        obj.define_singleton_method(:_, &self)
        obj.method(:_).to_proc
      end
    end
  end
end

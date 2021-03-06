# encoding: UTF-8
require 'active_support/core_ext/module/attribute_accessors'


module Adventura extend self
  autoload :World, 'adventura/world'

  autoload :Collection, 'adventura/collection'
  autoload :Transition, 'adventura/transition'
  autoload :Command, 'adventura/command'
  autoload :Interface, 'adventura/interface'

  autoload :Entity, 'adventura/entity'
  autoload :Action, 'adventura/action'
  autoload :Item, 'adventura/item'
  autoload :Room, 'adventura/room'
  autoload :Route, 'adventura/route'
  autoload :Event, 'adventura/event'
  autoload :Person, 'adventura/person'
  autoload :Player, 'adventura/player'
  autoload :Conversions, 'adventura/conversions'

  # @attribute [w]
  mattr_writer :world

  # @attribute [r]
  def player
    @player ||= Player.new(name)
  end

  # @attribute [rw]
  mattr_accessor :interface

  # @return [World]
  def world(*args, &block)
    @world ||= World.new(interface, player)
    @world.instance_exec(*args, &block) if block_given?
    @world
  end

  # Creates world according to specification in passed block
  # and starts it
  def start!(&block)
    init_handlers

    world.define(&block)
    world.spin!

    while command = interface.get_command(world.possible_commands)
      world.process command
    end
  end

  private
  def init_handlers
    trap('INT')  { exit }
    trap('TERM') { exit }
    trap('QUIT') { exit }
  end

  def name
    interface.ask "Your name is? "
  end
end

include Adventura::Conversions

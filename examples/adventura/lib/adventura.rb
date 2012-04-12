# encoding: UTF-8
require 'active_support/core_ext/module/attribute_accessors'


module Adventura
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

  mattr_writer :interface
  mattr_accessor :world
  mattr_reader :player

  extend self

  def interface
    @interface ||= Interface::Shell.new
  end

  def start!(&block)
    trap('INT')  { exit }
    trap('TERM') { exit }
    trap('QUIT') { exit }

    name = interface.ask "Your name is? "

    @@player = Player.new(name)
    @@world = World.new(interface, player, &block)

    world.spin!

    while command = interface.get_command(world.possible_commands)
      world.process command
    end
  end
end

include Adventura::Conversions

module Adventura
  class Game
    attr_reader :player, :world

    def initialize
      @player = Player.new
      @world = World.new(@player)
    end

  end
end

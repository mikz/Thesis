module Adventura
  class Route < Entity

    def destination
      super or dest
    end

    def direction
      super or dir
    end

    def dest
      super or id
    end

    def goes_to?(room)
      destination and room.to_sym == destination.to_sym
    end

    def goes?(way)
      direction and way.to_sym == direction.to_sym
    end

    def format
      parts = [ label ]
      parts << "to" << dest if dest?
      parts << "on" << dir if dir?
      parts.join(" ")
    end
  end
end

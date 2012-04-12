module Adventura
  class Room < Entity
    collections_of :routes, :items
    collection_of :persons, :as => :people

    def routes_to(room)
      routes.search { |route| route.goes_to?(room) }
    end

    def routes_on(direction)
      routes.search { |route| route.goes?(direction) }
    end
  end
end

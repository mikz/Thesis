module Adventura
  class Person < Entity
    collection_of :items, :as => :inventory

    def message(key)
      self.messages[key] or self.messages[:default]
    end

    def take(item, person)
      callback(:take, item, person) do
        inventory.take(item, person.inventory)
      end
    end

    def condition
      talk
    end

    def condition?
      talk?
    end
  end
end

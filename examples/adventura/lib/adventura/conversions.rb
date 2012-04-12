module Adventura
    module Conversions
    def Collection(array)
      collection = Adventura::Collection.new
      array.each do |entity|
        collection.set entity
      end
      collection
    end
  end
end

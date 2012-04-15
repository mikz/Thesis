module Adventura
  module Conversions

    # @return [Collection]
    def Collection(array)
      collection = Adventura::Collection.new
      array.each do |entity|
        collection.set entity
      end
      collection
    end
  end
end

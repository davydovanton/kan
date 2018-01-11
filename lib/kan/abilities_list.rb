module Kan
  class AbilitiesList
    def initialize(name, list)
      @name = name
      @list = list
    end

    def call(*payload)
      @list.first.ability(@name).call(*payload)
    end
  end
end

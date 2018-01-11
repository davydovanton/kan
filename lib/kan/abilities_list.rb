module Kan
  class AbilitiesList
    def initialize(name, list)
      @name = name
      @list = list
    end

    def call(*payload)
      @list
        .select { |abilities| abilities.class.valid_role?(*payload) }
        .any? { |abilities| abilities.ability(@name).call(*payload) }
    end
  end
end

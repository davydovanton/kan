module Kan
  class AbilitiesList
    def initialize(name, list, default_options = {})
      @name = name
      @list = list.map { |ability| ability.update_options(default_options) }
    end

    def call(*payload)
      @list
        .select { |abilities| abilities.class.valid_role?(*payload) }
        .any? { |abilities| abilities.ability(@name).call(*payload) }
    end
  end
end

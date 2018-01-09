module Kan
  class Application
    def initialize(abilities)
      @abilities = Hash(abilities)
    end

    def [](ability_name)
      ability, action_name = ability_name.split('.')
      @abilities[ability.to_sym].action(action_name)
    end
  end
end

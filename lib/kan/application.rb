module Kan
  class Application
    def initialize(scopes)
      @scopes = Hash(scopes)
    end

    def [](ability)
      scope, ability_name = ability.split('.')
      @scopes[scope.to_sym].ability(ability_name)
    end
  end
end

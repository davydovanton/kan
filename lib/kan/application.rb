module Kan
  class Application
    def initialize(scopes)
      @scopes = Hash(scopes)
    end

    def [](ability)
      scope, ability_name = ability.split('.')
      abilities = @scopes[scope.to_sym]

      if abilities
        abilities.ability(ability_name)
      else
        raise ArgumentError.new("Invalid scope #{scope}")
      end
    end
  end
end

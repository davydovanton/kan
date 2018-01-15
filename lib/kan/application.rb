module Kan
  class Application
    def self.default_options(options = {})
      @default_options = Hash(options)
    end

    def self.default_options
      @default_options || {}
    end

    def initialize(scopes)
      @scopes = Hash(scopes)
    end

    def [](ability)
      scope, ability_name = ability.split('.')

      abilities = Array(@scopes[scope.to_sym])
      raise_scope_error(scope) if abilities.empty?

      AbilitiesList.new(ability_name, abilities, self.class.default_options)
    end

    private

    def raise_scope_error(scope)
      raise ArgumentError.new("Invalid scope #{scope}")
    end
  end
end

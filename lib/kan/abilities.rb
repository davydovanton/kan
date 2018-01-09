module Kan
  module Abilities
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def register(*abilities, &block)
        @ability_list ||= {}
        abilities.each { |ability| @ability_list[ability.to_sym] = block }
      end

      def ability_list
        @ability_list || {}
      end
    end

    DEFAULT_ABILITY = proc { true }

    def ability(name)
      self.class.ability_list[name.to_sym] || DEFAULT_ABILITY
    end
  end
end

module Kan
  module Abilities
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def register(ability, &block)
        @ability_list ||= {}
        @ability_list[ability.to_sym] = block
      end

      def ability_list
        @ability_list || {}
      end
    end

    def ability(name)
      self.class.ability_list[name.to_sym]
    end
  end
end

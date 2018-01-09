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

    DEFAULT_ABILITY_BLOCK = proc { true }

    def initialize(options = {})
      @options = options
    end

    def ability(name)
      self.class.ability_list[name.to_sym] || @options[:default_ability_block] || DEFAULT_ABILITY_BLOCK
    end
  end
end

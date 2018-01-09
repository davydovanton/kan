module Kan
  module Ability
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def register(ability, &block)
        @action_list ||= {}
        @action_list[ability.to_sym] = block
      end

      def action_list
        @action_list || {}
      end
    end

    def action(name)
      self.class.action_list[name.to_sym]
    end
  end
end

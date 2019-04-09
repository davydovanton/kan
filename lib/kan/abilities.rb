require 'logger'

module Kan
  module Abilities
    def self.included(base)
      base.extend(ClassMethods)
    end

    class InvalidRoleObjectError < StandardError; end
    class InvalidAbilityNameError < StandardError; end
    class InvalidAliasNameError < StandardError; end

    module ClassMethods
      RESERVED_NAME = :roles.freeze
      DEFAULT_ROLE_NAME = :base
      DEFAULT_ROLE_BLOCK = proc { true }

      def register(*abilities, &block)
        abilities.map!(&:to_sym)
        raise InvalidAbilityNameError if abilities.include?(RESERVED_NAME)

        abilities.each do |ability|
          aliases.delete(ability)
          ability_list[ability] = block
        end
      end

      def register_alias(name, ability)
        normalized_name = name.to_sym
        normalized_ability = ability.to_sym
        raise InvalidAliasNameError if normalized_name == RESERVED_NAME

        aliases[normalized_name] = normalized_ability
      end

      def ability(name)
        normalized_name = name.to_sym
        ability = aliases.fetch(normalized_name, normalized_name)

        ability_list[ability]
      end

      def role(role_name, object = nil, &block)
        @role_name = role_name
        @role_block = object ? make_callable(object) : block
      end

      def role_name
        @role_name || DEFAULT_ROLE_NAME
      end

      def role_block
        @role_block || DEFAULT_ROLE_BLOCK
      end

      def valid_role?(*args)
        role_block.call(*args)
      end

      def ability_list
        @ability_list ||= {}
      end

      private

      def aliases
        @aliases ||= {}
      end

      def make_callable(object)
        callable_object = object.is_a?(Class) ? object.new : object

        return callable_object if callable_object.respond_to? :call

        raise InvalidRoleObjectError.new "role object #{object} does not support #call method"
      end
    end

    DEFAULT_ABILITY_BLOCK = proc { true }

    attr_reader :logger

    def initialize(options = {})
      @options = options
      @after_call_callback = options[:after_call_callback]
      @logger = @options.fetch(:logger, Logger.new(STDOUT))
    end

    def ability(name)
      normalized_name = name.to_sym
      rule = self.class.ability(normalized_name) || @options[:default_ability_block] || DEFAULT_ABILITY_BLOCK

      ->(*args) do
        result = instance_exec(args, &rule)
        @after_call_callback && @after_call_callback.call(normalized_name, args)
        result
      end
    end
  end
end

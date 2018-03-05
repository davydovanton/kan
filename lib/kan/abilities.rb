require 'logger'

module Kan
  module Abilities
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      DEFAULT_ROLE_NAME = :base
      DEFAULT_ROLE_BLOCK = proc { true }

      def register(*abilities, &block)
        @ability_list ||= {}
        abilities.each { |ability| @ability_list[ability.to_sym] = block }
      end

      def role(role_name, klass = nil, &block)
        @role_name = role_name
        @role_block = klass ? klass.new : block
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
        @ability_list || {}
      end
    end

    DEFAULT_ABILITY_BLOCK = proc { true }

    attr_reader :logger

    def initialize(options = {})
      @options = options
      @logger = @options.fetch(:logger, Logger.new(STDOUT))
    end

    def ability(name)
      rule = self.class.ability_list[name.to_sym] || @options[:default_ability_block] || DEFAULT_ABILITY_BLOCK
      lambda { |*args| instance_exec(args, &rule) }
    end
  end
end

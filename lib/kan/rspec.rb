module Kan
  module RSpec
    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :permit do |ability, *targets|
        match_proc = lambda do |app|
          app[ability].call(*targets)
        end

        match_when_negated_proc = lambda do |app|
          !app[ability].call(*targets)
        end

        failure_message_proc = lambda do |_app|
          target, action = ability.split('.')
          "Expected #{target} to grant #{action} but not granted"
        end

        failure_message_when_negated_proc = lambda do |_app|
          target, action = ability.split('.')
          "Expected #{target} not to grant #{action} but granted"
        end

        match(&match_proc)
        match_when_negated(&match_when_negated_proc)
        failure_message(&failure_message_proc)
        failure_message_when_negated(&failure_message_when_negated_proc)
      end
    end

    module DSL
      def permissions(&block)
        describe(caller: caller) { instance_eval(&block) }
      end
    end

    module AbilityExampleGroup
      include Kan::RSpec::Matchers

      def self.included(base)
        base.metadata[:type] = :ability
        base.extend Kan::RSpec::DSL
        super
      end
    end
  end
end

RSpec.configure do |config|
  if RSpec::Core::Version::STRING.split(".").first.to_i >= 3
    config.include(
      Kan::RSpec::AbilityExampleGroup,
      type: :ability,
      file_path: %r{spec/abilites}
    )
  else
    config.include(
      Kan::RSpec::AbilityExampleGroup,
      type: :ability,
      example_group: { file_path: %r{spec/abilites} }
    )
  end
end

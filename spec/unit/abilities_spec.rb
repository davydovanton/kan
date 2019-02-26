RSpec.describe Kan::Abilities do
  class PostAbilities
    include Kan::Abilities

    role(:manager) { |_, _| true }

    register('read') { |_| true }
    register(:edit) { |_, _| false }
  end

  class EmptyAbilities
    include Kan::Abilities

    role(:anonymous) { false }
  end

  class ArrayAbilities
    include Kan::Abilities

    register('read', :edit) { true }
    register('logger') { logger }
  end

  class AliasAbilities
    include Kan::Abilities

    register_alias('alias_before_ability', :read)

    register(:read) { true }
    register(:edit) { false }

    register_alias(:alias_after_ability, 'edit')
    register_alias(:overrided_alias, :edit)

    register(:overrided_alias) { true }
  end

  class LogAbilities
    include Kan::Abilities

    register('read') { logger }
  end

  let(:abilities) { PostAbilities.new }

  describe '::ability_list' do
    it { expect(EmptyAbilities.ability_list).to eq({}) }

    it { expect(PostAbilities.ability_list).to be_a Hash }
    it { expect(PostAbilities.ability_list.keys).to eq %i[read edit] }
  end

  describe '::role_name' do
    it { expect(EmptyAbilities.role_name).to eq :anonymous }
    it { expect(PostAbilities.role_name).to eq :manager }
    it { expect(ArrayAbilities.role_name).to eq :base }
  end

  describe '::role_block' do
    it { expect(EmptyAbilities.role_block.call).to eq false }
    it { expect(PostAbilities.role_block.call).to eq true }
    it { expect(ArrayAbilities.role_block.call).to eq true }
  end

  describe '#ability' do
    it { expect(abilities.ability('read')).to be_a Proc }

    it { expect(abilities.ability('read').call).to eq true }
    it { expect(abilities.ability('edit').call).to eq false }

    context 'with array register' do
      let(:abilities) { ArrayAbilities.new }

      it { expect(abilities.ability('read').call).to eq true }
      it { expect(abilities.ability('edit').call).to eq true }
    end

    context 'with empty register' do
      let(:abilities) { EmptyAbilities.new }

      it { expect(abilities.ability('read')).to be_a Proc }
      it { expect(abilities.ability('read').call).to eq true }
    end

    context 'with other default ability block' do
      let(:abilities) { EmptyAbilities.new(default_ability_block: proc { false }) }

      it { expect(abilities.ability('read')).to be_a Proc }
      it { expect(abilities.ability('read').call).to eq false }
    end

    context 'with default logger' do
      let(:abilities) { LogAbilities.new }

      it { expect(abilities.ability('read').call).to be_a Logger }
    end

    context 'with custom logger' do
      let(:logger) { double(Logger) }
      let(:abilities) { LogAbilities.new(logger: logger) }

      it { expect(abilities.ability('read').call).to be_a logger.class }
    end

    context 'with alias register' do
      let(:abilities) { AliasAbilities.new }

      it { expect(abilities.ability('alias_before_ability').call).to eq true }
      it { expect(abilities.ability(:alias_before_ability).call).to eq true }
      it { expect(abilities.ability(:alias_after_ability).call).to eq false }
      it { expect(abilities.ability(:overrided_alias).call).to eq true }
    end

    context 'when ability has wrong name' do
      it 'raises error' do
        expect do
          class WrongAbilities
            include Kan::Abilities

            register(:roles) { |_| true }
          end
        end.to raise_error(Kan::Abilities::InvalidAbilityNameError)
      end
    end

    context 'when alias has wrong name' do
      it 'raises error' do
        expect do
          class WrongAbilities
            include Kan::Abilities

            register(:read) { |_| true }
            register_alias(:roles, :read)
          end
        end.to raise_error(Kan::Abilities::InvalidAliasNameError)
      end
    end
  end
end

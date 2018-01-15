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

  let(:abilities) { PostAbilities.new }

  describe '::ability_list' do
    it { expect(EmptyAbilities.ability_list).to eq({}) }

    it { expect(PostAbilities.ability_list).to be_a Hash }
    it { expect(PostAbilities.ability_list.keys).to eq [:read, :edit] }
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

  describe '#action' do
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

    context 'with logger' do
      let(:abilities) { ArrayAbilities.new }

      it { expect(abilities.ability('logger').call).to be_a Logger }
    end
  end
end

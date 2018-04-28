RSpec.describe Kan::AbilitiesList do
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
  end

  let(:list) { [PostAbilities.new, EmptyAbilities.new, ArrayAbilities.new] }
  let(:ability_name) { 'edit' }
  let(:abilities_list) { described_class.new(ability_name, list) }

  describe '#call' do
    subject { abilities_list.call(a: 1) }

    context 'when roles are match' do
      context 'and ability alows' do
        let(:list) { [PostAbilities.new, EmptyAbilities.new, ArrayAbilities.new] }

        it { expect(subject).to eq true }
      end

      context 'and ability does not alow' do
        let(:list) { [PostAbilities.new, EmptyAbilities.new] }

        it { expect(subject).to eq false }
      end
    end

    context 'when roles are not match' do
      let(:list) { [EmptyAbilities.new] }

      it { expect(subject).to eq false }
    end

    context 'when ability name detect roles' do
      let(:ability_name) { 'roles' }

        it { expect(subject).to eq [:manager, :base] }
    end
  end
end

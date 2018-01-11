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

    it { expect(subject).to eq false }
  end
end

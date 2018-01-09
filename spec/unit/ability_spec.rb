RSpec.describe Kan::Ability do
  class PostAbilities
    include Kan::Ability

    register('read') { |_| true }
    register('edit') { |_, _| false }
  end

  class EmptyAbilities
    include Kan::Ability
  end

  let(:abilities) { PostAbilities.new }

  describe '::action_list' do
    it { expect(EmptyAbilities.action_list).to eq({}) }

    it { expect(PostAbilities.action_list).to be_a Hash }
    it { expect(PostAbilities.action_list.keys).to eq [:read, :edit] }
  end

  describe '#action' do
    it { expect(abilities.action('read')).to be_a Proc }
    it { expect(abilities.action('read').call).to eq true }
    it { expect(abilities.action('edit').call).to eq false }
  end
end

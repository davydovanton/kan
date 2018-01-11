RSpec.describe Kan::Application do
  class PostAbilities
    include Kan::Abilities

    register('read') { |_| true }
    register('edit') { |_, _| false }
  end

  class UserAbilities
    include Kan::Abilities

    register('read') { false }
  end

  let(:app) do
    Kan::Application.new(
      user: UserAbilities.new,
      post: PostAbilities.new
    )
  end

  describe '[]' do
    it { expect(app['post.read']).to be_a Kan::AbilitiesList }

    it { expect(app['post.read'].call).to eq true }
    it { expect(app['post.edit'].call).to eq false }

    it { expect(app['user.read']).to be_a Kan::AbilitiesList }

    it { expect(app['user.read'].call).to eq false }

    context 'when ability does not exist' do
      it { expect(app['user.not_exist'].call).to eq true }
    end

    context 'when scope does not exist' do
      it { expect { app['tasks.read'].call }.to raise_error 'Invalid scope tasks' }
    end
  end
end

RSpec.describe 'Rolle class' do
  class AdminRole
    def call(user, _)
      user.admin?
    end
  end

  class AdminPostAbilities
    include Kan::Abilities

    role :admin, AdminRole

    register('read') { |_| true }
  end

  describe 'when abilities set as array' do
    let(:app) { Kan::Application.new(post: [AdminPostAbilities.new]) }
    let(:ability) { app['post.read'] }

    context 'and user is admin' do
      let(:admin) { double(:user, admin?: true) }

      it { expect(ability.call(admin, nil)).to eq true }
    end

    context 'and user is regular user' do
      let(:user) { double(:user, admin?: false) }

      it { expect(ability.call(user, nil)).to eq false }
    end
  end
end

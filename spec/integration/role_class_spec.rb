RSpec.describe 'Rolle class' do
  class AdminRole
    def call(user, _)
      user.admin?
    end
  end

  let(:admin_post_abilities) do
    Class.new do
      include Kan::Abilities
      role :admin, AdminRole
      register('read') { |_| true }
    end
  end

  describe 'when abilities set as array' do
    let(:app) { Kan::Application.new(post: [admin_post_abilities.new]) }
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

  describe 'when role is object' do
    let(:admin_post_abilities) do
      Class.new do
        include Kan::Abilities
        role :admin, AdminRole.new
        register('read') { |_| true }
      end
    end

    let(:app) { Kan::Application.new(post: [admin_post_abilities.new]) }
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

  describe 'when abilities set as object' do
    let(:app) { Kan::Application.new(post: admin_post_abilities.new) }
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

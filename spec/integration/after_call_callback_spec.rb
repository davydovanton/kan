RSpec.describe 'after_call_callback' do
  let(:callback) { spy }
  let(:app) do
    Kan::Application.new(
      ability_with_callback: UserAbilities.new(
        after_call_callback: -> (ability_name, payload) { callback.call(ability_name, payload) }
      )
    )
  end

  class UserAbilities
    include Kan::Abilities

    register(:read) { |user, _| true }
  end

  it do
    app['ability_with_callback.read'].call('user', 'something')
    expect(callback).to have_received(:call).with(:read, ['user', 'something'])
  end
end

require 'dry/auto_inject'

RSpec.describe 'with dry inject' do
  class PostAbilities
    include Kan::Abilities

    register('read') { |_| true }
    register('edit') { |_, _| false }
  end

  class UserAbilities
    include Kan::Abilities

    register('read') { false }
  end

  App = Kan::Application.new(
    user: UserAbilities.new,
    post: PostAbilities.new
  )

  AbilitiesImport = Dry::AutoInject(App)

  class Operation
    include AbilitiesImport[ability_checker: 'post.edit']

    def call(params = {})
      ability_checker.call(params)
    end
  end

  let(:operation) { Operation.new }

  it { expect(operation.call).to eq false }
end

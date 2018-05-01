## Testing

For expample we have a simple kan class:

```ruby

module Comments
  module Roles
    class Admin
      def call(user, _)
        user.admin?
      end
    end
  end

  class Abilities
    include Kan::Abilities

    role :admin, Roles::Admin.new

    register('read') { |user, _| user&.id }

    register('edit') do |user, comment|
      user.id == comment.id || user.admin?
    end
  end
end
```

### Ability

For testing specific ability use `#ability` Abilities method:

```ruby
RSpec.describe Comments::Abilities do
  let(:abilities) { described_class.new }

  subject { ability.call(account, nil) }

  describe 'read ability' do
    let(:ability) { abilities.ability(:read) } # it will return proc object

    context 'when user login' do
      let(:user) { User.new(id: 1) }

      it { expect(subject).to eq true }
    end

    context 'when user anonymous' do
      let(:user) { User.new(id: 1) }

      it { expect(subject).to eq false }
    end
  end
end
```

Or testing specific ability using custom matchers:

```ruby
RSpec.describe Comments::Abilities, type: :ability do
  subject do
    Kan::Application.new(
      user:    Users::Abilities.new,
      comment: Comments::Abilities.new
    )
  end

  describe 'read ability' do
    context 'when user login' do
      let(:user) { User.new(id: 1) }
      it { is_expected.to permit('comment.read', user) }
    end

    context 'when user anonymous' do
      let(:user) { User.new(id: 1) }
      it { is_expected.not_to permit('comment.read', user) }
    end
  end
end
```

### Role

For testing role you can use two ways. The first - test role object:

```ruby
RSpec.describe Comments::Abilities, type: :ability do
  let(:role) { Comments::Role::Admin.new }

  subject { role.call(user) }

  context 'when user admin' do
    let(:user) { User.new(admin: true) }

    it { expect(subject).to be_true }
  end

  context 'when user anonymous' do
    let(:user) { User.new(admin: false) }

    it { expect(subject).to be_false }
  end
end
```

Or use `#role_block` class method:

```ruby
RSpec.describe Comments::Abilities, type: :ability do
  let(:role) { Comments::Abilities.role_block }

  subject { role.call(user) }

  context 'when user admin' do
    let(:user) { User.new(admin: true) }

    it { expect(subject).to be_true }
  end

  context 'when user anonymous' do
    let(:user) { User.new(admin: false) }

    it { expect(subject).to be_false }
  end
end
```

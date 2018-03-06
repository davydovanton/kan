# Kan
[![Build Status](https://travis-ci.org/davydovanton/kan.svg?branch=master)](https://travis-ci.org/davydovanton/kan)

Simple functional authorization library for ruby. Inspired by [transproc](https://github.com/solnic/transproc) and [dry project](http://dry-rb.org)

## Table of context

* [Installation](#installation)
* [Usage](#usage)
  * [Register abilities](#register-abilities)
  * [Check abilities](#check-abilities)
    * [Default ability block](#default-ability-block)
    * [List of abilities](#list-of-abilities)
  * [Roles](#roles)
    * [Class objects as role](#class-objects-as-role)
    * [Callable objects as role](#callable-objects-as-role)
  * [Dry-auto\_inject](#dry-auto_inject)
* [Contributing](#contributing)
* [License](#license)
* [Code of Conduct](#code-of-conduct)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kan

## Usage

### Register abilities

```ruby
class Post::Abilities
  include Kan::Abilities

  register('read') { |_, _| true }
  register('edit') { |user, post| user.id == post.user_id }
  register('delete') { |_, _| false }
end
```

Also, you can register more than one ability in one place and use string or symbol keys:

```ruby
class Post::AdminAbilities
  include Kan::Abilities

  register(:read, :edit, :delete) { |user, _| user.admin? }
end

class Comments::Abilities
  include Kan::Abilities

  register('read') { |_, _| true }
  register('edit') { |user, _| user.admin? }

  register(:delete) do |user, comment|
    user.id == comment.user_id && comment.created_at < Time.now + TEN_MINUTES
  end
end
```

### Check abilities

```ruby
abilities = Kan::Application.new(
  post: Post::Abilities.new,
  comment: Comments::Abilities.new
)

abilities['post.read'].call(current_user, post) # => true
abilities['post.delete'].call(current_user, post) # => false
abilities['comment.delete'].call(current_user, post) # => false
```

#### Default ability block

By default Kan use `proc { true }` as a default ability block:

```ruby
abilities['comment.invalid'].call(current_user, post) # => true
```

But you can rewrite it

```ruby
admin_abilities = Kan::Application.new(
  post: Post::AdminAbilities.new(default_ability_block: proc { false }),
  comment: Comments::Abilities.new,
)

admin_abilities['post.delete'].call(current_user, post)  # => false
admin_abilities['post.delete'].call(admin_user, post)    # => true
admin_abilities['post.invalid'].call(current_user, post) # => false
```

#### List of abilities
You can provide array of abilities for each scope and Kan will return `true` if at least one ability return `true`:

```ruby
global_abilities = Kan::Application.new(
  post: [Post::Abilities.new, Post::AdminAbilities.new],
  comment: Comments::Abilities.new
)

global_abilities['post.edit'].call(current_user, post) # => false
global_abilities['post.edit'].call(owner_user, post)   # => true
global_abilities['post.edit'].call(admin_user, post)   # => true
```

### Roles
Kan provide simple role system. For this you need to define role block in each abilities classes:
```ruby
module Post
  class AnonymousAbilities
    include Kan::Abilities

    role(:anonymous) do |user, _|
      user.id.nil?
    end

    register(:read, :edit, :delete) { false }
  end

  class BaseAbilities
    include Kan::Abilities

    role(:all) do |_, _|
      true
    end

    register(:read) { |_, _| true }
    register(:edit, :delete) { |user, post| false }
  end


  class AuthorAbilities
    include Kan::Abilities

    role(:author) do |user, post|
      user.id == post.author_id
    end

    register(:read, :edit) { |_, _| true }
    register(:delete) { |_, _| false }
  end

  class AdminAbilities
    include Kan::Abilities

    role(:admin) do |user, _|
      user.admin?
    end

    register(:read, :edit, :delete) { |_, _| true }
  end
end
```

After that initialize Kan application object and call it with payload:
```ruby
abilities = Kan::Application.new(
  post: [Post::AnonymousAbilities.new, Post::BaseAbilities.new, Post::AuthorAbilities.new, Post::AdminAbilities.new],
  comment: Comments::Abilities.new
)

abilities['post.read'].call(anonymous, post) # => false
abilities['post.read'].call(regular, post)   # => true
abilities['post.read'].call(author, post)    # => true
abilities['post.read'].call(admin, post)     # => true

abilities['post.edit'].call(anonymous, post) # => false
abilities['post.edit'].call(regular, post)   # => false
abilities['post.edit'].call(author, post)    # => true
abilities['post.edit'].call(admin, post)     # => true

abilities['post.delete'].call(anonymous, post) # => false
abilities['post.delete'].call(regular, post)   # => false
abilities['post.delete'].call(author, post)    # => false
abilities['post.delete'].call(admin, post)     # => true
```

#### Class objects as role

Kan allow to use classes as roles for incapulate and easily testing your roles.
```ruby
module Post
  module Roles
    class Admin
      def call(user, _)
        user.admin?
      end
    end

    class Anonymous
      def call(user, _)
        user.id.nil?
      end
    end
  end

  class AnonymousAbilities
    include Kan::Abilities

    role :anonymous, Anonymous

    register(:read, :edit, :delete) { false }
  end

  class AdminAbilities
    include Kan::Abilities

    role :admin, Roles::Admin

    register(:read, :edit, :delete) { |_, _| true }
  end
end
```

#### Callable objects as role

Kan allow to use "callable" (objects with `#call` method) as a role object. For this just put it into ability class:
```ruby
module Post
  module Roles
    class Admin
      def call(user, _)
        user.admin?
      end
    end

    class Anonymous
      def call(user, _)
        user.id.nil?
      end
    end
  end

  class AnonymousAbilities
    include Kan::Abilities

    role :anonymous, Anonymous.new

    register(:read, :edit, :delete) { false }
  end

  class AdminAbilities
    include Kan::Abilities

    role :admin, Container['post.roles.admin'] # or use dry-container

    register(:read, :edit, :delete) { |_, _| true }
  end
end
```

### Logger support
By default kan support default ruby logger (`Logger.new` class). For setup custom logger you can use `logger` option for each abilities instances:
```ruby
abilities = Kan::Application.new(
  comment: Comments::Abilities.new(logger: MyCustomLogger.new)
)
```

And call it from ability block:
```ruby
class AnonymousAbilities
  include Kan::Abilities

  register(:read, :edit, :delete) do
    logger.info 'Anonymous ability checked'
    false
  end
end
```

### Dry-auto\_inject
```ruby
AbilitiesImport = Dry::AutoInject(Kan::Application.new({}))

# Operation

class UpdateOperation
  include AbilitiesImport[ability_checker: 'post.edit']

  def call(user, params)
    return Left(:permission_denied) unless ability_checker.call(user)
    # ...
  end
end

# Specs

UpdateOperation.new(ability_checker: ->(*) { true })
UpdateOperation.new(ability_checker: ->(*) { false })
```

### Testing

For expample we have a simple kan class:

```ruby
class Comments::Abilities
  include Kan::Abilities

  register('read') { |user, _| user&.id }

  register('edit') do |user, comment|
    user.id == comment.id || user.admin?
  end
end
```

#### Specific ability
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/kan. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### How to instal the project
Just clone repository and call:

```
$ bundle install
$ bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davydovanton/kan/blob/master/CODE_OF_CONDUCT.md).

# Kan

Simple fundctional authorization library for ruby. Inspired by [transproc](https://github.com/solnic/transproc)

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

```ruby
class Abilities
  extend Kan::Processing
end

class Post::Abilities
  extend Kan::Abilities

  register 'read' { |_, _| true }
  register 'edit' { |user, post| user.id == post.user_id }
  register 'delete' { |_, _| false }
end

# register more than one ability in one place
class Post::AdminAbilities
  extend Kan::Abilities

  register :read, :edit, :delete { |user, _| user.admin? }
end

class Comments::Abilities
  extend Kan::Abilities

  register 'read' { |_, _| true }
  register 'edit' { |user, _| user.admin? }

  register :delete do |user, comment|
    user.id == comment.user_id && comment.created_at < Time.now + TEN_MINUTES
  end
end

abilities = Abilities.new(
  post: Post::Abilities,
  comment: Comments::Abilities,
)

abilities['post.read'].call(current_user, post) # => true
abilities['post.delete'].call(current_user, post) # => false

abilities['comment.delete'].call(current_user, post) # => false

admin_abilities = Abilities.new(
  post: Post::AdminAbilities,
  comment: Comments::Abilities,
)

admin_abilities['post.delete'].call(current_user, post) # => false
admin_abilities['post.delete'].call(admin_user, post) # => true

global_abilities = Abilities.new(
  post: [Post::Abilities, Post::AdminAbilities],
  comment: Comments::Abilities,
)

global_abilities['post.edit'].call(current_user, post) # => false
global_abilities['post.edit'].call(owner_user, post) # => true
global_abilities['post.edit'].call(admin_user, post) # => true
```

### Dry-auto\_inject
```ruby
AbilitiesImport = Dry::AutoInject(Abilities.new)

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/kan. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kan/blob/master/CODE_OF_CONDUCT.md).

# Kan
[![Build Status](https://travis-ci.org/davydovanton/kan.svg?branch=master)](https://travis-ci.org/davydovanton/kan)

Simple functional authorization library for ruby. Inspired by [transproc](https://github.com/solnic/transproc) and [dry project](http://dry-rb.org)

## Table of context

* [Installation](#installation)
* [Usage](#usage)
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

See [User Documentation page](https://blog.davydovanton.com/kan/)

* [Base Usage](https://blog.davydovanton.com/kan/)
* [Roles](https://blog.davydovanton.com/kan/roles)
* [Testing](https://blog.davydovanton.com/kan/testing)
* [Dry integration](https://blog.davydovanton.com/kan/working_with_dry)
* [F.A.Q.]()https://blog.davydovanton.com/kan/faq

## Basic Usage

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

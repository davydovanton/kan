# Kan
[![Build Status](https://travis-ci.org/davydovanton/kan.svg?branch=master)](https://travis-ci.org/davydovanton/kan)
[![Backers on Open Collective](https://opencollective.com/kan/backers/badge.svg)](#backers)
 [![Sponsors on Open Collective](https://opencollective.com/kan/sponsors/badge.svg)](#sponsors)

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

See [User Documentation page](http://kanrb.org/)

* [Basic Usage](http://kanrb.org/basic_usage)
* [Roles](http://kanrb.org/roles)
* [Testing](http://kanrb.org/testing)
* [Dry integration](http://kanrb.org/working_with_dry)
* [F.A.Q.](http://kanrb.org/faq)

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

### Code and features

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/kan. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Docs
Just send PR with changes in `docs/` folder.

### How to instal the project
Just clone repository and call:

```
$ bundle install
$ bundle exec rspec
```

## Contributors

This project exists thanks to all the people who contribute.
<a href="https://github.com/davydovanton/kan/contributors"><img src="https://opencollective.com/kan/contributors.svg?width=890&button=false" /></a>


## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/kan#backer)]

<a href="https://opencollective.com/kan#backers" target="_blank"><img src="https://opencollective.com/kan/backers.svg?width=890"></a>


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/kan#sponsor)]

<a href="https://opencollective.com/kan/sponsor/0/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/1/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/2/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/3/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/4/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/5/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/6/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/7/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/8/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/kan/sponsor/9/website" target="_blank"><img src="https://opencollective.com/kan/sponsor/9/avatar.svg"></a>



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davydovanton/kan/blob/master/CODE_OF_CONDUCT.md).

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

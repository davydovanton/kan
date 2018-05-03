## F.A.Q.

> In the example "Also, you can register more than one ability in one place and use string or symbol keys:", I don't understand how these ablities are triggered -- do PostAbilities and AdminAbilities somehow both apply at once? Can you add to this example to show how you'd call the auth check, and what would be checked?

Kan will call each ability object from your register list. If all objects return `false` `abilities[name].call(payload)` will return `false` too. I.e.:

```ruby
abilities = Kan::Application.new(
  post: [Post::Abilities.new, Post::AdminAbilities.new],
  comment: Comments::Abilities.new
)

# [Post::Abilities.new -> false, Post::AdminAbilities.new -> false] -> false
abilities['post.edit'].call(current_user, post)
# => false

# [Post::Abilities.new -> true, Post::AdminAbilities.new -> false] -> true
global_abilities['post.edit'].call(owner_user, post)
# => true

# [Post::Abilities.new -> false, Post::AdminAbilities.new -> true] -> true
abilities['post.edit'].call(admin_user, post)
# => true
```

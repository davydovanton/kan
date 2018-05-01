# Roles
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

## Class objects as role

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

## Callable objects as role

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

    role :anonymous, Roles::Anonymous.new

    register(:read, :edit, :delete) { false }
  end

  class AdminAbilities
    include Kan::Abilities

    role :admin, Container['post.roles.admin'] # or use dry-container

    register(:read, :edit, :delete) { |_, _| true }
  end
end
```

## Detect Roles
Kan allow to detect all roles for specific payload. For this use `roles` calls in scope:

```ruby
module Post
  class AnonymousAbilities
    include Kan::Abilities

    role :anonymous, Roles::Anonymous.new
    register(:read, :edit, :delete) { false }
  end

  class AdminAbilities
    include Kan::Abilities

    role :admin, Roles::Admin.new
    register(:read, :edit, :delete) { |_, _| true }
  end
end

abilities = Kan::Application.new(
  post: [AnonymousAbilities.new, AdminAbilities.new]
)

abilities['post.roles'].call(anonymous_user, payload) # => [:anonymous]
abilities['post.roles'].call(admin_user, payload)     # => [:anonymous, :admin]

```

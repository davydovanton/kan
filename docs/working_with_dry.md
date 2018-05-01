## Dry-auto\_inject

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

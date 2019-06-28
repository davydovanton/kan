# typed: true

module Kan
end

class Kan::AbilitiesList
  def ability_check(payload); end
  def call(*payload); end
  def initialize(name, list); end
  def mapped_roles(payload); end
end

class Kan::Application
  def [](ability); end
  def initialize(scopes = nil); end
  def raise_scope_error(scope); end
end

class Kan::Application::InvalidScopeError < StandardError
end

module Kan::Abilities
  def ability(name); end
  def initialize(options = nil); end
  def logger; end
  def self.included(base); end
end

class Kan::Abilities::InvalidRoleObjectError < StandardError
end

class Kan::Abilities::InvalidAbilityNameError < StandardError
end

class Kan::Abilities::InvalidAliasNameError < StandardError
end

module Kan::Abilities::ClassMethods
  def ability(name); end
  def ability_list; end
  def aliases; end
  def make_callable(object); end
  def register(*abilities, &block); end
  def register_alias(name, ability); end
  def role(role_name, object = nil, &block); end
  def role_block; end
  def role_name; end
  def valid_role?(*args); end
end

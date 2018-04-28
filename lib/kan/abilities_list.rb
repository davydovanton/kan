module Kan
  class AbilitiesList
    ROLES_DETECT = 'roles'

    def initialize(name, list)
      @name = name
      @list = list
    end

    def call(*payload)
      @name == ROLES_DETECT ? mapped_roles(payload) : ability_check(payload)
    end

  private

    def ability_check(payload)
      @list
        .select { |abilities| abilities.class.valid_role?(*payload) }
        .any? { |abilities| abilities.ability(@name).call(*payload) }
    end

    def mapped_roles(payload)
      @list.map do |abilities|
        abilities.class.valid_role?(*payload) ? abilities.class.role_name : nil
      end.compact
    end
  end
end

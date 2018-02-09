require 'spec_helper'

RSpec.describe Kan::Application, type: :ability do
  class PostAbilities
    include Kan::Abilities

    register('read') { |_| true }
    register('edit') { |_, _| false }
  end

  class UserAbilities
    include Kan::Abilities

    register('read') { false }
  end

  subject do
    Kan::Application.new(
      user: UserAbilities.new,
      post: PostAbilities.new
    )
  end

  permissions do
    it "denies access for post edit" do
      expect(subject).not_to permit('post.edit')
    end

    it "grants access for post read" do
      expect(subject).to permit('post.read')
    end

    it "denies access for user read" do
      expect(subject).not_to permit('user.read')
    end
  end
end

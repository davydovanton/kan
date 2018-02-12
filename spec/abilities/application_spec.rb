require 'spec_helper'

RSpec.describe Kan::Application, type: :ability do
  module CustomMatcher
    class PostAbilities
      include Kan::Abilities

      register(:read) { |_| true }
      register(:edit) { |user, post| user.id == post.user_id }
    end

    class UserAbilities
      include Kan::Abilities

      register(:read) { |_| true }
      register(:delete) { |user, _| user.admin? }
    end
  end

  let(:user)       { double('User', id: 1, admin?: false) }
  let(:admin)      { double('User', id: 2, admin?: true) }
  let(:post)       { double('Post', user_id: user.id) }
  let(:other_post) { double('Post', user_id: admin.id) }

  subject do
    Kan::Application.new(
      user: CustomMatcher::UserAbilities.new,
      post: CustomMatcher::PostAbilities.new
    )
  end

  permissions do
    describe "Post Abilities" do
      it "grant all access for read" do
        expect(subject).to permit('post.read', user, post)
        expect(subject).to permit('post.read', user, other_post)
      end

      it "grant owner access for edit" do
        expect(subject).to permit('post.edit', user, post)
        expect(subject).not_to permit('post.edit', user, other_post)
      end
    end

    describe "User Abilities" do
      it "grant all users access for read" do
        expect(subject).to permit('user.read', user)
      end

      it "deny normal user access for delete" do
        expect(subject).not_to permit('user.delete', user)
        expect(subject).to permit('user.delete', admin)
      end
    end
  end
end

require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:mark)
    @other = users(:pikachu)
  	log_in_as(@user)
  end

  test "following page" do
  	get following_user_path(@user)
  	assert_not @user.following.empty?
  	assert_match @user.following.count.to_s, response.body
  	@user.following.each do |user|
  		assert_select "a[href=?]", user_path(user)
  	end
  end

  test "followers page" do
  	get followers_user_path(@user)
  	assert_not @user.followers.empty? # Include this to ensure that assert_select below isn't vacuously true.
  	assert_match @user.followers.count.to_s, response.body
  	@user.followers.each do |user|
  		assert_select "a[href=?]", user_path(user)
  	end
  end

  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  # Tests the Ajax method of following a user by setting xhr (XmlHttpRequest) to true,
  # which issues an Ajax request in the test, which causes respond_to block in
  # relationships_controller to execute proper JavaScript method.
  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

   test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
end

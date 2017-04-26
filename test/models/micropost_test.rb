require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
  	@user = users(:mark)
  	# @micropost = Micropost.new(content: "lorem ipsum", user_id: @user.id) # This code is not idiomatically correct.
  	@micropost = @user.microposts.build(content: "Lorem ipsum") # As with .new (and unlike .create/.create!), .build creates an object in memory but doesn't modify the database.
  end

  test "should be valid" do
  	assert @micropost.valid?
  end

  test "user id should be present" do
  	@micropost.user_id = nil
  	assert_not @micropost.valid?	
  end

  test "content should be present" do
  	@micropost.content = "  "
  	assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
  	@micropost.content = "a" * 141
  	assert_not @micropost.valid?
  end

  test "order should be most recent first" do
  	assert_equal microposts(:most_recent), Micropost.first
  end
end

require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
 
 def setup
 	@user = users(:mark)
 end

 test "profile display" do
 	get user_path(@user)
 	assert_template 'users/show'
 	assert_select 'title', full_title(@user.name)
 	assert_select 'h1', text: @user.name
 	# Nesting syntax for assert_select.
 	# Checks for img tag with class .gravatar inside a top-level heading tag (h1).
 	assert_select 'h1>img.gravatar'
 	# This is much less specific than assert_select, since response.body returns the full HTML source.
 	assert_match @user.microposts.count.to_s, response.body
 	assert_select 'div.pagination', count: 1
 	@user.microposts.paginate(page: 1).each do |micropost|
 		# RAILS AUTOMATICALLY ESCAPES ANY CONTENT INSERTED INTO VIEW TEMPLATES
 		# TO PREVENT CROSS-SITE SCRIPTING (XSS) ATTACKS!
 		assert_match micropost.content, response.body
 	end
 end
end

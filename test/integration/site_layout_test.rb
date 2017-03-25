require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "layout links" do
  	get root_path
  	assert_template 'static_pages/home'
  	assert_select "a[href=?]", root_path, count: 2
  	assert_select "a[href=?]", help_path
    assert_select "a[href=?]", login_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get signup_path
    assert_select "title", full_title("Sign up")
    assert_select "a[href=?]", users_path, count: 0
    log_in_as(users(:mark))
    follow_redirect! # why is this necessary?
    assert_select "a[href=?]", users_path
	end
end

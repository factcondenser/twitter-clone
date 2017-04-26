require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
  	ActionMailer::Base.deliveries.clear
  	@user = users(:mark)
  end

  test "password resets" do
  	get new_password_reset_path
  	assert_template 'password_resets/new'
  	# Invalid email
  	post password_resets_path, params: { password_reset: { email: "" } }
  	assert_not flash.empty?
  	assert_template 'password_resets/new'
  	# Valid email
  	post password_resets_path, params: { password_reset: { email: @user.email } }
  	assert_not_equal @user.reset_digest, @user.reload.reset_digest
  	assert_equal 1, ActionMailer::Base.deliveries.size
	assert_not flash.empty?
	assert_redirected_to root_url
	# Password reset form
	user = assigns(:user) # Why is this necessary? Assigns @user from password_resets controller.
	# Wrong email
	get edit_password_reset_path(user.reset_token, email: "")
	assert_redirected_to root_url
	# Inactive user
	user.toggle!(:activated)
	get edit_password_reset_path(user.reset_token, email: user.email)
	assert_redirected_to root_url
	user.toggle!(:activated)
	# Right email, wrong token
	get edit_password_reset_path('wrong token', email: user.email)
	assert_redirected_to root_url
	# Right email, right token
	get edit_password_reset_path(user.reset_token, email: user.email)
	assert_template 'password_resets/edit'
	assert_select "input[name=email][type=hidden][value=?]", user.email # Test for presence of the hidden email field.
	# Invalid password & confirmation
	patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "foobaz", password_confirmation: "barquux" } } # Use params[:user][:password] here because these are f.*_field.
	assert_select 'div#error_explanation'
	# Empty password
	patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "", password_confirmation: "" } }
	assert_select 'div#error_explanation'
	# Vailid password & confirmation
	patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "foobaz", password_confirmation: "foobaz" } }
	assert is_logged_in?
	assert_nil user.reload.reset_digest # Don't forget to reload the user, since the update action makes a change to the db!
	assert_not flash.empty?
	assert_redirected_to user
  end

  test "expired token" do
  	get new_password_reset_path
  	post password_resets_path, params: { password_reset: { email: @user.email } }
  	# Assigns @user from password_resets controller.
  	@user = assigns(:user)
  	@user.update_attribute(:reset_sent_at, 3.hours.ago) # Force token to expire.
  	patch password_reset_path(@user.reset_token), params: { email: @user.email, user: { password: "foobar", password_confirmation: "foobar" } }
  	assert_response :redirect
  	follow_redirect!
  	assert_match /expired/i, response.body
  end
end

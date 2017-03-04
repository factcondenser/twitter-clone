require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
 # test "the truth" do
 #   assert true
 # end
	test "invalid signup information" do
		get signup_path
  	assert_no_difference 'User.count' do
  		assert_select 'form[action="/signup"]'
  		post signup_path, params: { user: { name: "",
  											email: "user@invalid",
  											password: "foo",
  											password_confirmation: "bar"} }
		end
		assert_template 'users/new'
		
		# error message tests
		assert_select '#error_explanation' do
			assert_select 'li', 4
			assert_select 'li', "Name can't be blank"
			assert_select 'li', "Email is invalid"
			assert_select 'li', "Password confirmation doesn't match Password"
			assert_select 'li', "Password is too short (minimum is 6 characters)"
		end	
		assert_select '.field_with_errors', 8
	end

	test "valid signup information" do
		get signup_path
		assert_difference 'User.count', 1 do
			post signup_path, params: { user: {  name: "Example User",
																					email: "user@example.com",
																					password: "password",
																					password_confirmation: "password"} }
		end
		follow_redirect!
		assert_template 'users/show'

		# flash test
		assert_not flash.empty?
	end
end

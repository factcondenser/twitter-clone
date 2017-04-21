require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:mark)
		@nonactivated_user = users(:non)
	end

	test "show only activated users" do
		log_in_as(@admin)
		get user_path(@nonactivated_user)
		assert_redirected_to root_url
	end
end

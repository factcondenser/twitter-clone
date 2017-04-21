require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
	# Log in, visit the index path, verify the first page of users is present, and then confirm that pagination is present on the page.
	def setup
		@admin = users(:mark)
		@non_admin = users(:anny)
	end

	test "index as admin including pagination and delete links" do
		log_in_as(@admin)
		get users_path
		assert_template 'users/index'
		assert_select 'div.pagination', count = 2
		first_page_of_users = User.paginate(page: 1)
		first_page_of_users.each do |user|
			unless not user.activated?
				assert_select 'a[href=?]', user_path(user), text: user.name
				unless user == @admin
					assert_select 'a[href=?]', user_path(user), text: 'delete'
				end
			end
		end
		assert_difference 'User.count', -1 do
			delete user_path(@non_admin)
		end
	end

	test "index as non-admin" do
		log_in_as(@non_admin)
		get users_path
		assert_select 'a', text: 'delete', count: 0
	end

	test "index displays only activated users" do
		log_in_as(@admin)
		get users_path
		paginated_users = assigns(:users)
		paginated_users.each do |user|
			assert_equal true, user.activated?
		end
	end
end

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	test "full title helper" do
		assert_equal full_title, "Ruby on Rails Tutorial Twitter Clone"
		assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Twitter Clone"
		assert_equal full_title("Contact"), "Contact | Ruby on Rails Tutorial Twitter Clone"
		assert_equal full_title("About"), "About | Ruby on Rails Tutorial Twitter Clone"		
	end
end
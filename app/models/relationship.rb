class Relationship < ApplicationRecord
	belongs_to :follower, class_name: "User"
	belongs_to :followed, class_name: "User" 
	# As of Rails 5, these validations are unnecessary, but we include them here for completeness.
	validates :follower_id, presence: true
	validates :followed_id, presence: true
end

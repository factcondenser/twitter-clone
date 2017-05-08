class User < ApplicationRecord
	# Attributes
	has_many :microposts, dependent: :destroy # Assoicate user with his/her microposts and arrange for dependent microposts to be destroyed when corresponding users are destroyed.
	# Have to specify class_name and foreign_key b/c:
	# 1) Rails uses Classify method to determine class based on symbol name.
	# This would give ActiveRelationship, which doesn't exist.
	# 2) Rails expects foreign_key of form <class>_id, where <class> is lower-case version of class name.
	# This would be user_id, but user following another user is now identified with follower_id.
	has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	# Rails would see ":followeds" and use the singular "followed", assembling a collection using the followed_id in the relationships table.
	# But user.followeds is awkward, so we use user.following instead and tell Rails that the source of the :following array is the set of followed ids.
	# Could technically omit source key for followers, but we keep it here to emphasize the parallel structure.
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower
	attr_accessor	:remember_token, :activation_token, :reset_token # As required by the virtual nature of these tokens (ie they're not in the db)
	before_save		:downcase_email
	before_create	:create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i 
	validates :email, presence: true, length: { maximum: 255 },
										format: { with: VALID_EMAIL_REGEX},
										uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	# Class methods (idiomatically correct, if confusing)
	class << self
		# Returns the hash digest b of the given string.
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end

		# Returns a random token.
		def new_token
			SecureRandom.urlsafe_base64
		end
	end

	# Instance methods
	# Remembers a user in the database for use in persistent sessions.
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# Returns true if the given token matches the digest (generalized; 11.3.1)
	def authenticated?(attribute, token)
		digest = self.send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	# Activates an account.
	def activate
		# Hits the database once.
		update_columns(activated: true, activated_at: Time.zone.now)
		# Hits the database twice, which is less efficient.
		# update_attribute(:activated, true)
		# update_attribute(:activated_at, Time.zone.now)
	end

	# Sends activation email.
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	# Sets the password reset attributes.
	def create_reset_digest
		self.reset_token = User.new_token
		update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
		# Hits the database twice, which is less efficient.
		# update_attribute(:reset_digest, User.digest(reset_token))
		# update_attribute(:reset_sent_at, Time.zone.now)
	end

	# Sends password reset email.
	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end
	
	# Returns true if a password reset has expired.
	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end
	
	# Defines a proto-feed.
	# See "Following users" for the full implementation.
	def feed
		# Use the ? to ensure that id is properly escaped before being included in underlying SQL query.
		# Thus, avoid serious security hole called SQL injection.
		# id here is just an integer (i.e. self.id), so no harm.
		# But always escaping variables injected into SQL statements is a good habit.
		#Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
		# following_ids is a shortcut for the system-to-proc notation: following.map(&:id)
		# When inserting into an SQL string, don't need to convert arrays to string since ? interpolation
		# takes care of this (and also eliminates some database-dependent incompatibilities),
		# so we can use following_ids by itself!

		# Replace Ruby code, following_ids, with SQL snippet below.
		# This code contains an SQL subselect, which arranges for all the set logic to be pushed
		# into the database, which is more efficient.
		following_ids = "SELECT followed_id FROM relationships WHERE  follower_id = :user_id"
    	# Question mark syntax from above is equivalent, but when we want the
    	# *same* variable inserted in more than one place, the below syntax is more convenient.
    	Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
	end

	# Follows a user.
	def follow(other_user)
		following << other_user
	end

	# Unfollows a user.
	def unfollow(other_user)
		following.delete(other_user)
	end

	# Returns true if the current user is following the other user.
	def following?(other_user)
		following.include?(other_user)
	end

	# Returns true if the current user is followed by the other user.
	# Technically unnecessary, but I include it to parallel the above method.
	def followed_by?(other_user)
		followers.include?(other_user)
	end

	private

		# Converts email to all lower-case.
		def downcase_email
			email.downcase! # Also can be written as self.email = email.downcase; normally prefer method reference, not explicit block
		end

		# Creates and assigns the activation token and digest.
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end
end

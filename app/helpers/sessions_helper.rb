module SessionsHelper
	
	# Logs in the given user.
	def log_in(user)
		session[:user_id] = user.id
	end

	# Provides access to current user.
	def current_user
		# Syntax 1
		#if @current_user.nil?
		#	@current_user = User.find_by(id: session[:user_id])
		#else
		#	@current_user

		# Syntax 2
		#@current_user = @current_user || User.find_by(id: session[:user_id])

		# Correct Syntax
		@current_user ||= User.find_by(id: session[:user_id])
	end

	def logged_in?
		!current_user.nil?
	end

	# Logs out the current user.
	def log_out
		session.delete(:user_id)
		# Technically unnecessary since @current_user created after destroy action and followed immediately by redirect.
		@current_user = nil
	end
end

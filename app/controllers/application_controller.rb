class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  #def hello
  	#render html: "Dis ma twitta klone, y'all!"
  #end

  private

    # Confirms a logged-in user.
  	def logged_in_user
  		unless logged_in?
  			store_location
  			flash[:danger] = "Please log in."
  			redirect_to login_url
  		end
  	end
end

class MicropostsController < ApplicationController
	before_action :logged_in_user, only: [:create, :destroy]
	before_action :correct_user, only: :destroy

	def create
		@micropost = current_user.microposts.build(micropost_params)
		# See Rails Tutorial 13.3.3
		@feed_items = current_user.feed.paginate(page: params[:page])
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_url
		else
			# @feed_items = [] # ??? WTF Hartl. WHy is this the "easiest" solution?
			render 'static_pages/home'
		end
	end

	def destroy
		@micropost.destroy
		flash[:success] = "Micropost deleted"
		# request.referrer is just the prev page; in some tests this is nil, so just redirect to home.
		redirect_to request.referrer || root_url
		# Starting in Rails 5, could also use:
		#redirect_back(fallback_location: root_url)
	end

	private

		def micropost_params
			params.require(:micropost).permit(:content, :picture)
		end

		def correct_user
			@micropost = current_user.microposts.find_by(id: params[:id])
			redirect_to root_url if @micropost.nil?
		end
end

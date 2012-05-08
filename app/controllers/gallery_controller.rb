require 'net/http'

class GalleryController < ApplicationController
  def index
  end

  def show
  	puts "SHOW SHOW SHOW"
  	if params.has_key?("url")
  		@page = Net::HTTP.get(URI.parse(params[:url]))
  	end
  	
  	render :layout => :nil
  end
end

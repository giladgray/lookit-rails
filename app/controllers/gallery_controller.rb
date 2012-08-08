require 'net/http'

class GalleryController < ApplicationController
  def index
  end

  def show
  	puts "SHOW SHOW SHOW"
  	if params.has_key?("url")
      url = params[:url]
      url = "http://" + url unless url.start_with? 'http'
  		@page = Net::HTTP.get(URI.parse(url))
  	end
  	
  	render :layout => false
  end

  def spine
  end
end

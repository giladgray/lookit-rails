require 'net/http'

class GalleryController < ApplicationController

  # from http://stackoverflow.com/posts/6934503/revisions
  def fetch_uri(uri_str, limit = 10, parent = nil)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    uri = URI.parse(uri_str)
    if uri.host.nil?
      uri.host = parent.host
      uri.scheme = parent.scheme
    puts "    #{parent.to_s} => #{uri.host}"
    end
    puts "fetching #{uri.to_s}... (#{limit})"
    response = Net::HTTP.get_response(URI.parse(uri.to_s))
    case response
      when Net::HTTPSuccess     then [uri.to_s, response.body]
      when Net::HTTPRedirection then fetch_uri(response['location'], limit - 1, uri)
      else response.error!
    end
  end

  def index
  end

  def show
  	if params.has_key?("url")
      url = params[:url]
      url = "http://" + url unless url.start_with? 'http'
  		@page = Net::HTTP.get(URI.parse(url)) #fetch url
  	end
  	
  	render :layout => false
  end

  def spine
  end

  def fetch
    if params.has_key?("url")
      url = params[:url]
      url = "http://" + url unless url.start_with? 'http'
      @page = fetch_uri url
    end
    
    render 'show', :layout => false
  end
end

require 'sinatra/base'

class ApplicationController < Sinatra::Application

  # Set the settings for the application.
  configure do
    set :root, File.expand_path('../../..', __FILE__)
    set :views, settings.root + '/app/views'
    set :content_dir, settings.root + '/content'
    set :master_branch, 'master'
  end

  # Set the settings for development.
  configure :development do
    disable :dump_errors
  end

  def reject?(path)
    # Accept if there is no path.
    return false if path == nil

    # Reject if path is not base64.
    begin
      Base64.urlsafe_decode64 path
    rescue ArgumentError
      return true
    end

    # Reject if path contains '..'.
    # TODO: Write this.

    # Reject if path is shorter than content_dir.
    # TODO: Write this.

    # Otherwise accept.
    return false
  end

end

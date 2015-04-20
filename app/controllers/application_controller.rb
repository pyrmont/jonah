require 'sinatra/base'
require 'base64'

class ApplicationController < Sinatra::Application

  configure do
    set :root, File.expand_path('../../..', __FILE__)
    set :views, settings.root + '/app/views'
    set :content_dir, settings.root + '/content'
    set :master_branch, 'master'
  end

  configure :development do
    disable :dump_errors
  end

  # DESCRIPTION
  # Reject the path if it is invalid.
  #
  # PARAMETERS
  # path   (String) A directory somewhere in the content directory. This variable is expected to be
  #                 Base64-encoded.
  #
  # EXPLANATION
  # First, check if the path is empty. Return false if it is and nil is allowed (otherwise return
  # false). Then check if the path is not Base64-encoded. Return true if it is. Otherwise return false.
  def reject?(path, empty_allowed: true)
    if path == nil
      return false if empty_allowed == true
      return true if empty_allowed == false
    end

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

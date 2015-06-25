require 'sinatra/base'
require 'base64'
require 'git'

class ApplicationController < Sinatra::Application

  configure do
    set :root, File.expand_path('../../..', __FILE__)
    set :views, settings.root + '/app/views'
    set :content_dir, settings.root + '/content'
    set :master_branch, 'master'
    set :extensions, ['txt', 'md', 'markdown', 'text']

    use Rack::Session::Cookie,
      :key => 'rack.session',
      :secret => 'super_secret'
  end

  configure :development do
    disable :dump_errors
  end

  # DESCRIPTION
  # Get a message based on a particular message code.
  #
  # PARAMETERS
  # message_code   (Symbol) A message_code.
  #
  # RETURN
  # Return a status message.
  def get_message(message_code)
    message = case message_code
              when :save_ok then 'File saved.'
              else 'This message code was not recognised.'
              end
  end

  # DESCRIPTION
  # Reject the path if it is invalid.
  #
  # PARAMETERS
  # path   (String) A directory somewhere in the content directory. This
  #                 variable is expected to be Base64-encoded.
  #
  # RETURN
  # Return boolean result of whether the path should be rejected.
  #
  # EXPLANATION
  # First, check if the path is empty. Return false if it is and nil is allowed
  # (otherwise return false). Then check if the path is not Base64-encoded.
  # Return true if it is. Otherwise return false.
  def reject?(path, filename: false)
    return true if filename && (path == nil || path.strip == '')

    begin
      decoded_path = (path == nil || path == '') ? '' : Base64.urlsafe_decode64(path)
    rescue ArgumentError
      return true
    end

    # Reject if path starts with '/'.
    return true if decoded_path.start_with? '/'

    # Reject if path starts with '.'.
    return true if decoded_path.start_with? '.'

    # Reject if path contains '..'.
    return true if decoded_path.include? '/../'

    # Reject if path contains '.'.
    return true if decoded_path.include? '/./'

    # Otherwise accept.
    return false
  end

end

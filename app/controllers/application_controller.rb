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

    use Rack::Session::Cookie, :key => 'rack.session', :secret => 'super_secret'
  end

  configure :development do
    disable :dump_errors
  end

  # DESCRIPTION
  # Return the name of the current branch in the repository.
  #
  # PARAMETERS
  # :repo   (Git::Base or Nil) The repository object returned by the get_repo() method.
  #
  # RETURN
  # Return the current branch as a String (return an error message fi the repository is nil).
  def current_branch(repo)
    return "Error: Repository not editable" if repo == nil
    repo.current_branch
  end

  # DESCRIPTION
  # Checks if the repo is editable.
  #
  # PARAMETERS
  # :repo   (Git::Base or Nil) The repository object returned by the get_repo() method.
  #
  # RETURN
  # Return boolean result of whether the repo is editable.
  def editable?(repo)
    repo == nil ? false : true
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
  # Returns the repository.
  #
  # PARAMETERS
  # :path   (String) The content directory.
  # :master (Symbol) The name of the master branch.
  #
  # RETURN
  # Return a Git::Base repository.
  def get_repo(path, master)
    repo = Git.open(path)
  end

  # DESCRIPTION
  # Reject the path if it is invalid.
  #
  # PARAMETERS
  # path   (String) A directory somewhere in the content directory. This variable is expected to be
  #                 Base64-encoded.
  #
  # RETURN
  # Return boolean result of whether the path should be rejected.
  #
  # EXPLANATION
  # First, check if the path is empty. Return false if it is and nil is allowed (otherwise return
  # false). Then check if the path is not Base64-encoded. Return true if it is. Otherwise return false.
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

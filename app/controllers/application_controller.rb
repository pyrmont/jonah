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

end

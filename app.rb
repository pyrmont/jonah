require 'sinatra'

# Import specific Jonah controllers.
require './controllers/base_controller'
require './controllers/list_controller'
require './controllers/edit_controller'

# Set the directory for the files used to build the site.
config = Hash.new
config[:app_root] = File.dirname(__FILE__) + '/'
config[:repo_root] = config[:app_root] + 'content/'

# Create the controllers.
list = ListController.new config
edit = EditController.new config

get '/list/?:path?' do
  # Generate the list.
  @content = list.index params[:path]

  # Render the template.
  erb :list
end

get '/list/branch/:path' do
  # Create the branch.
  list.branch params[:path]

  # Display the list again.
  redirect to '/list/' + params[:path]
end
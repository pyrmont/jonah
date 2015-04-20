require 'base64'
require 'git'

class EditController < ApplicationController

  # DESCRIPTION
  # Display the content of a file in the editor for a given path.
  #
  # PARAMETERS
  # :path   (String) A file somewhere in the content directory. This variable is expected to be
  #                  Base64-encoded.
  #
  # EXPLANATION
  # First, set the path variable. Then check if the path is valid and halt processing if not (rendering
  # an error template). If the path is valid, decode the path and then create a content variable. Then
  # render the edit template.
  get '/:path' do
    path = params[:path]
    halt 400, erb(:error) if reject? path
    decoded_path = Base64.urlsafe_decode64 path

    @content = Hash.new
    @content['filename'] = File.basename decoded_path
    @content['contents'] = read_file decoded_path

    puts settings.static

    erb :edit
  end

  private

    # DESCRIPTION
    # Read the contents of a given file into a String.
    #
    # PARAMETERS
    # path   (String) A file somewhere in content directory.
    #
    # RETURN
    # Return the contents of the file.
    def read_file(path)
      contents = IO.read path
      return contents
    end

end
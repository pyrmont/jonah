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
    halt 400, erb(:error) if reject? path, empty_allowed: false
    decoded_path = Base64.urlsafe_decode64 path

    @content = Hash.new
    @content['filename'] = File.basename decoded_path
    @content['contents'] = read_file decoded_path
    @content['path'] = path

    erb :edit
  end

  # DESCRIPTION
  # Save the content of the file.
  #
  # EXPLANATION
  # First, set the path variable based on the submitted path parameter. Then check if the path is valid
  # (a path must be provided otherwise the code will be halted). If the path is valid, decode the path
  # and then extract the contents from the parameters hash. Then write the contents to the file. Last
  # redirect to the route for that path.
  #
  # TODO
  # There needs to be some sort of nonce for security.
  post '/save' do
    path = params[:path]
    halt 400, erb[:error] if reject? path, empty_allowed: false
    decoded_path = Base64.urlsafe_decode64 path

    contents = params[:contents]
    write_file decoded_path, contents

    redirect to('/' + path)
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
    end

    # DESCRIPTION
    # Write the contents of a given String into a file.
    #
    # PARAMETERS
    # path       (String) A file somewhere in content directory.
    # contents   (String) The contents to paste.
    def write_file(path, contents)
      IO.write path, contents
    end

end
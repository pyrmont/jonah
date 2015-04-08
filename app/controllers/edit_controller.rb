require 'base64'
require 'git'

class EditController < ApplicationController

  get '/:path' do
    path = params[:path]

    # Return an error if the directory check fails.
    halt 400, erb(:error) if reject? params[:path]

    # Add contents of the file.
    @content = Hash.new
    @content['contents'] = read_file params[:path]

    puts settings.static

    erb :edit
  end

  private

    def read_file(path)
      # Decode path.
      decoded_path = Base64.urlsafe_decode64 path

      # Read contents of file.
      contents = IO.read decoded_path

      # Return contents.
      return contents
    end

end
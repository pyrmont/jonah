require 'base64'
require 'git'

class EditController < ApplicationController

  get '/:path' do
    path = params[:path]

    # Return an error if the directory check fails.
    halt 400, erb(:error) if reject? path

    # Decode path.
    decoded_path = Base64.urlsafe_decode64 path

    @content = Hash.new

    # Add filename.
    @content['filename'] = File.basename decoded_path

    # Add contents of the file.
    @content['contents'] = read_file decoded_path

    puts settings.static

    erb :edit
  end

  private

    def read_file(path)
      # Read contents of file.
      contents = IO.read path

      # Return contents.
      return contents
    end

end
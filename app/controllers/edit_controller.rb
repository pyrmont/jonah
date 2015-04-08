class EditController < ApplicationController

  get '/:path' do
    # Return an error if the directory check fails.
    halt 400, 'Error' if reject? params[:path]

    # Add list of entries to the content.
    @content = Hash.new
    @content['contents'] = read_file params[:path]

    erb :edit
  end

  private

    def reject?(path)
      return false
    end

    def read_file(path)
      # Read contents of file.
      contents = ''

      # Return contents.
      return contents
    end

end
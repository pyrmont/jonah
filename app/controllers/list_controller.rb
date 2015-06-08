require 'base64'
require 'git'

require_relative '../models/repository'
require_relative '../models/post'

class ListController < ApplicationController

  ListItem = Struct.new :name, :path, :full_path, :is_file, :encoded_path, :uri, :is_editable

  before do
    @repo = Repository.new settings.content_dir
  end

  # DESCRIPTION
  # List the files in the given path.
  #
  # PARAMETERS
  # :path   (String) A directory somewhere in the content directory. This variable is expected to be
  #                  Base64-encoded.
  #
  # EXPLANATION
  # First, check if the path has been set (and assigns it nil if not). Then check if the path is valid
  # and halt processing if not (rendering an error template). If the path is valid, build a directory
  # listing for the list template. Then render the list template.
  get '/:path?' do
    path = (params[:path]) ? params[:path] : nil
    halt 400, erb(:error) if reject? path

    decoded_path = (path) ? Base64.urlsafe_decode64(path) : ''
    items = create_list decoded_path
    encoded_path = (path) ? '' : Base64.urlsafe_encode64(decoded_path)

    erb :list, :locals => { :repo => @repo, :items => items, :parent_dir => encoded_path}
  end

  private

    # DESCRIPTION
    # Create an array of ListItems for a given path.
    #
    # PARAMETERS
    # path   (String) A directory somewhere in the content directory.
    #
    # RETURN
    # Returns an Array of ListItems (possibly empty).
    #
    # EXPLANATION
    # First, decode the path parameter if it exists. Then set the current_dir to this path or, if no
    # path has been given, to the settings.content_dir variable. Then get the list of files in
    # current_dir. Based on this list, create a ListItem object and add it to the array. Return the
    # array.
    def create_list(path)
      current_dir = path
      entries = Dir.entries(settings.content_dir + '/' + current_dir)

      list = Array.new
      entries.each do |entry|
        list_item = create_item entry, current_dir
        list.push list_item unless list_item == nil
      end

      list
    end

    # DESCRIPTION
    # Create a ListItem object for a given filename.
    #
    # PARAMETERS
    # filename      (String) The filename.
    # current_dir   (String) The current directory.
    #
    # RETURN
    # Returns a ListItem object or nil (if there was an error).
    #
    # EXPLANATION
    # First, return nil if the filename is the current directory, the Git directory or (if we are at
    # the top of the content directory) the parent directory. Set the parent directory and then create
    # the ListItem object. Return the ListItem object.
    def create_item(filename, current_dir)
      return nil if (filename == '.' || filename.start_with?('.')) ||
                    (filename == '..' && current_dir == '')

      path = if (filename == '..')
               current_dir
             else
               if (current_dir == '')
                 filename
               else
                 current_dir + '/' + filename
               end
             end

      list_item = ListItem.new
      list_item.name = filename
      list_item.path = path
      list_item.full_path = settings.content_dir + '/' + list_item.path
      list_item.is_file = File.file? list_item.full_path
      list_item.encoded_path = Base64.urlsafe_encode64 list_item.path
      list_item.uri = ((list_item.is_file) ? '/edit/' : '/list/') + list_item.encoded_path
      list_item.is_editable = editable? list_item.name

      list_item
    end

    # DESCRIPTION
    # Checks if a file is editable.
    #
    # PARAMETERS
    # filename      (String) The filename.
    #
    # RETURN
    # Return a boolean result.
    #
    # EXPLANATION
    # First, get the extension based on the filename. Then, check if the extension exists in the
    # settings.extensions variable set in ApplicationController.
    def editable?(filename)
      extension = (File.extname filename)[1..-1]
      settings.extensions.include? extension
    end

end
require 'base64'
require 'git'

class ListController < ApplicationController

  ListItem = Struct.new :name, :path, :is_file, :encoded, :uri

  before do
    @repo = Git.open(settings.content_dir)
    @is_editable = !@repo.branches[settings.master_branch.to_sym].current
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
  # and halt processing if not (rendering an error template). If the path is valid, create a content
  # variable for use in the template. Then render the list template.
  get '/:path?' do
    path = (params[:path]) ? params[:path] : nil

    halt 400, erb(:error) if reject? path

    @content = Hash.new
    @content['entries'] = build_list path
    @content['is_editable'] = @is_editable

    erb :list
  end

  # DESCRIPTION
  # Create a branch for the given directory.
  #
  # PARAMETERS
  # :path   (String) A directory somewhere in the content directory. This variable is expected to be
  #                  Base64-encoded.
  #
  # TODO
  # It makes no sense to have a branch happen relative to a directory. Furthermore, this should be a
  # post action, not a get action.
  get '/branch/:path' do
    return 'Error' if reject? path
  end

  private

    # DESCRIPTION
    # Create an array of ListItems for a given path (path is expected to be encoded in Base64).
    #
    # PARAMETERS
    # path   (String) A directory somewhere in the content directory. This variable is expected to be
    #                 Base64-encoded.
    #
    # RETURN
    # Returns an Array of ListItems (possibly empty).
    #
    # EXPLANATION
    # First, decode the path parameter if it exists. Then set the current_dir to this path or, if no
    # path has been given, to the settings.content_dir variable. Then get the list of files in
    # current_dir. Based on this list, create a ListItem object and add it to the array. Return the
    # array.
    def build_list(path)
      decoded_path = (path) ? Base64.urlsafe_decode64(path) : false
      current_dir = (decoded_path) ? decoded_path : settings.content_dir
      entries = Dir.entries current_dir

      list = Array.new
      entries.each do |entry|
        list_item = create_item entry, current_dir
        list.push list_item unless list_item == nil
      end

      return list
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
      return nil if (filename == '.' || filename == '.git') ||
                    (filename == '..' && current_dir == settings.content_dir)

      parent_dir = File.dirname(current_dir)

      list_item = ListItem.new
      list_item.name = filename
      list_item.path = (list_item.name == '..') ? parent_dir : current_dir + '/' + list_item.name
      list_item.is_file = File.file? list_item.path
      list_item.encoded = Base64.urlsafe_encode64(list_item.path)
      list_item.uri = ((list_item.is_file) ? '/edit/' : '/list/') + list_item.encoded

      return list_item
    end

end
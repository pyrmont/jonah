require 'base64'
require 'git'

class ListController < ApplicationController

  ListItem = Struct.new :name, :path, :is_file, :encoded, :uri

  before do
    @repo = Git.open(settings.content_dir)
    @is_editable = !@repo.branches[settings.master_branch.to_sym].current
  end

  get '/:path?' do
    path = (params[:path]) ? params[:path] : nil

    # Return an error if the directory check fails.
    halt 400, erb(:error) if reject? path

    # Create the @content variable.
    @content = Hash.new

    # Add list of entries to the content.
    @content['entries'] = build_list path

    # Add whether edit mode is on to the content.
    @content['is_editable'] = @is_editable

    erb :list
  end

  get '/branch/:path' do
    # Return an error if the directory check fails.
    return 'Error' if reject? path

  end

  private

    def reject?(path)
      # Accept if there is no path.
      return false if path == nil

      # Reject if path is not base64.
      begin
        Base64.urlsafe_decode64(path)
      rescue ArgumentError
        return true
      end

      # Reject if path contains '..'.
      # TODO: Write this.

      # Reject if path is shorter than content_dir.
      # TODO: Write this.

      # Otherwise accept.
      return false
    end

    def build_list(path)
      # Decode path parameter if it exists.
      decoded_path = (path) ? Base64.urlsafe_decode64(path) : false

      # Set current directory
      current_dir = (decoded_path) ? decoded_path : settings.content_dir

      # Get the files in the current directory.
      entries = Dir.entries current_dir

      # Create list of files and directories.
      list = Array.new

      # Create a list item object for each entry and add it to the list.
      entries.each do |entry|
        list_item = create_item entry, current_dir
        list.push list_item unless list_item == nil
      end

      return list
    end

    def create_item(entry, current_dir)
      # Return nil if entry is the current directory, the Git directory or the parent directory above
      # the content_dir.
      return nil if (entry == '.' || entry == '.git') ||
                    (entry == '..' && current_dir == settings.content_dir)

      # Set the parent directory.
      parent_dir = File.dirname(current_dir)

      # Create the list item.
      list_item = ListItem.new
      list_item.name = entry
      list_item.path = (list_item.name == '..') ? parent_dir : current_dir + '/' + list_item.name
      list_item.is_file = File.file? list_item.path
      list_item.encoded = Base64.urlsafe_encode64(list_item.path)
      list_item.uri = ((list_item.is_file) ? '/edit/' : '/list/') + list_item.encoded

      return list_item
    end

end
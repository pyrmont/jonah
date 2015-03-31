require 'base64'
require 'git'

class ListController < BaseController

  ListItem = Struct.new :name, :path, :is_file, :encoded, :uri

  def index(path)
    # Return an error if the directory check fails.
    return 'Error' if reject? path

    # Add list of entries to the content.
    @content['entries'] = build_list path

    # Add whether edit mode is on to the content.
    @content['editable'] = editable? path

    return @content
  end

  def branch(path)
  end

  private

    def reject?(path)
      # Reject if path contains '..'.
      # TODO: Write this.

      # Reject if path is shorter than content_dir.
      # TODO: Write this.

      return false
    end

    def build_list(path)
      # Decode path parameter if it exists.
      decoded_path = (path) ? Base64.urlsafe_decode64(path) : false

      # Set current directory
      current_dir = (decoded_path) ? decoded_path : @content_dir

      # Set parent directory.
      parent_dir = (current_dir == @content_dir) ? false : File.dirname(current_dir)

      # Get the files in the current directory.
      entries = Dir.entries current_dir

      # Create list of files and directories.
      list = Array.new

      # Create a list item object for each entry and add it to the list.
      entries.each do |entry|
        list_item = create_item entry
        list.push list_item unless list_item == nil
      end

      return list
    end

    def create_item(entry)
      # Return nil if entry is the current directory, the Git directory or the parent directory above the content_dir.
      return nil if (entry == '.' || entry == '.git') || (entry == '..' && current_dir == @content_dir)

      list_item = ListItem.new
      list_item.name = entry
      list_item.path = (list_item.name == '..') ? parent_dir : current_dir + list_item.name
      list_item.is_file = File.file? list_item.path
      list_item.encoded = (list_item.is_file) ? Base64.urlsafe_encode64(list_item.path) : Base64.urlsafe_encode64(list_item.path + '/')
      list_item.uri = (list_item.is_file) ? '/edit/' + list_item.encoded : '/list/' + list_item.encoded

      return list_item
    end

    def editable?(path)
      return true
    end

end
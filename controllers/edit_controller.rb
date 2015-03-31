class EditController < BaseController

  def index(path)
    # Return an error if the directory check fails.
    return 'Error' if reject? path

    # Add list of entries to the content.
    @content['contents'] = read_file path

    return @content
  end

  private

    def reject?(path)
      # Reject if path contains '..'.
      # TODO: Write this.

      # Reject if path is shorter than content_dir.
      # TODO: Write this.

      # Reject if file doesn't exist.
      # TODO: Write this.

      # Reject if branch hasn't been created.
      # TODO: Write this.

      return false
    end

    def read_file(path)
      # Read contents of file.
      contents = ''

      # Return contents.
      return contents
    end

end
require 'base64'

class Post

  attr_accessor :path, :content
  attr_reader :content_dir, :full_path, :encoded_path, :basename, :parent, :encoded_parent

  def initialize(content_dir, path)
    @content_dir = content_dir
    @path = path
    @full_path = content_dir + '/' + path
    @encoded_path = Base64.urlsafe_encode64 path
    @content = (File.exist? @full_path) ? IO.read(@full_path) : nil
    @basename = File.basename @path
    @parent = (File.dirname(@path) == '.') ? '' : File.dirname(@path)
    @encoded_parent = Base64.urlsafe_encode64 @parent
  end

  def save
    IO.write @full_path, @content unless @content == nil
  end
end
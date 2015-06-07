require 'base64'

class Post

  attr_accessor :path, :content
  attr_reader :encoded_path, :basename, :parent, :encoded_parent

  def initialize(path)
    @path = path
    @encoded_path = Base64.urlsafe_encode64 path
    @content = (File.exist? @path) ? IO.read(@path) : nil
    @basename = File.basename @path
    @parent = File.dirname @path
    @encoded_parent = Base64.urlsafe_encode64 @parent
  end

  def save
    IO.write @path, @content unless @content == nil
  end
end
class BaseController

  def initialize(config)
    @app_root = config[:app_root]
    @repo_root = config[:repo_root]
    @content_dir = config[:repo_root]
    @content = Hash.new
  end

end
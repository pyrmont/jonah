require 'git'

class Repository
  def initialize(path)
    @repo = Git.open(path)
  end

  def editable?
    true
  end

  def current_branch
    @repo.current_branch
  end

  def commit(files, message)
    files = (files.is_a? Array) ? files : Array(files)

    files.each do |file|
      @repo.add file.path
    end

    @repo.commit message
  end
end
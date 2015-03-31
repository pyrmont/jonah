require 'git'

# Open the repository.
g = Git.open repo_root
puts g.branches

# Create a new branch as a test.
g.branch('my_branch').checkout
puts g.branches

# Create file.
File.write "#{content_dir}test.txt", ''

# Add all files in content_dir.
g.add :all => true

# Commit the files.
g.commit 'Add test file.'

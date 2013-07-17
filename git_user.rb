
class GitUser
  attr_accessor :src_name, :src_email
  attr_accessor :dst_name, :dst_email
  attr_accessor :commit_count, :lines_added, :lines_removed, :files_changed

  ANIMALS = %w(otter whale shark starfish sardine crab octopus frog lion hippo giraffe).shuffle

  def initialize(commit)
    @src_name = @dst_name = commit.author.name
    @src_email = @dst_email = commit.author.email
    @commit_count = @lines_added = @lines_removed = @files_changed = 0
  end

  def self.users
    @@users ||= {}
  end

  def self.user_for_commit(commit)
    user = users[commit.author.email] || GitUser.new(commit)
    user.commit_count += 1
    #user.lines_added += .....
    user.dst_name = random_sea_animal
    user.dst_email = "#{user.dst_name}@example.com"
    users[commit.author.email] = user
    puts users.collect {|k,v| [k, v.dst_name, v.commit_count] }.inspect
    user
  end

  def self.random_sea_animal
    @@animals ||= ANIMALS
    @@animals.pop
  end
end

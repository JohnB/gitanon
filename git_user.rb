
class GitUser
  attr_accessor :src_name, :src_email
  attr_accessor :dst_name, :dst_email
  attr_accessor :commit_count, :lines_added, :lines_removed, :files_changed
  attr_accessor :oldest_date, :oldest_sha, :newest_date, :newest_sha

  # collect more from http://www.npwrc.usgs.gov/about/faqs/animals/names.htm or
  # http://en.wikipedia.org/wiki/List_of_animal_names
  ANIMALS = %w(otter whale shark starfish sardine crab octopus frog lion hippo giraffe rhino ocelot
              serval okapi gazelle impala gerbil aardvark bat crocodile skink kudu eagle vulture
              wren dog hamster iguana jackal lemur cobra partridge tiger waterbuck badger buffalo
              elephant ferret fox goat gorilla horse hyena kangaroo leopard mole monkey mule pig
              porcupine
            ).shuffle

  def initialize(commit)
    @src_name = @dst_name = commit.author.name
    @src_email = @dst_email = commit.author.email
    @commit_count = @lines_added = @lines_removed = @files_changed = 0
    @dst_name = random_animal
    @dst_email = "#{@dst_name}@example.com"
  end

  def self.users
    @@users ||= {}
  end

  def self.user_for_commit(commit)
    user = users[commit.author.email]
    unless user
      user = GitUser.new(commit)
      users[commit.author.email] = user
    end
    users[commit.author.email].update_commit_stats(commit)
    puts users.collect {|k,v| [k, v.dst_name, v.commit_count, v.oldest_sha, v.oldest_date, v.newest_sha, v.newest_date] }.inspect
    users[commit.author.email]
  end

  def random_animal
    @@animals ||= ANIMALS
    @@animals.pop
  end

  def update_commit_stats(commit)
    @commit_count += 1
    if @oldest_date.nil? || commit.authored_date < @oldest_date
      @oldest_date = commit.authored_date
      @oldest_sha = commit.sha
    end
    if @newest_date.nil? || commit.authored_date > @newest_date
      @newest_date = commit.authored_date
      @newest_sha = commit.sha
    end

    #@lines_added += .....
  end
end

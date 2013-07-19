require 'grit'
require 'yaml'
require File.dirname(__FILE__) + '/git_user'

class GitAnon
  DEFAULT_CONFIG_NAME = ".gitanon"
  attr_reader :config_filename, :source_repo, :users

  def initialize(filename_or_hash = nil)
    if filename_or_hash.is_a?(Hash)
      @config = filename_or_hash
      @source_repo = @config['source_repo'] if valid_source_repo?(@config['source_repo'])
      @destination_repo = @config['destination_repo']
    else
      @config = {}
      load_config(filename_or_hash)
    end
  end

  def anonymize
    if valid_config?
      collect_branches
      collect_users
      verify_user_aliases
      collect_object_names
      verify_object_aliases
    else
      ask_for('destination_repo')
      ask_for('source_repo')
      collect_branches
      collect_users
      verify_user_aliases
      ask_for('primary_user')
      ask_for('source_start_date')
      ask_for('source_end_date')
      ask_for('destination_start_date')
      ask_for('story_regex')
      ask_for('defect_regex')
      collect_object_names
      verify_object_aliases
    end
    branches.each do |branch|
      copy_branch(branch)
    end
    update_user_stats
  end

  def load_config(filename)
    @config_filename = filename
    @config = begin
        YAML.load_file(filename)
      rescue
        {}
    end
    puts @config.inspect
  end
  def save_config
    puts "saving #{@config.inspect}"
    if @config_filename
      File.open(@config_filename, 'w') {|f| f.write YAML.dump_stream(@config) }
    end
  end

  def standard_config_fields
    ['source_repo', 'destination_repo', 'primary_user', 'source_start_date', 'source_end_date', 'destination_start_date', 'story_regex', 'defect_regex']
  end

  def valid_config?
    return false if @config.nil? || @config.empty?
    standard_config_fields.each do |field|
      validator = "valid_#{field}?"
      if self.respond_to?(validator)
        return false unless self.send(validator, @config[field])
      end
    end
    true
  end

  def ask_for(field)
    prompt_method = "prompt_for_#{field}"
    validate_method = "valid_#{field}?"
    msg = respond_to?(prompt_method) ? self.send(prompt_method) : field.capitalize.gsub(/_/,' ')
    current = @config[field]
    valid = false
    until valid do
      print "#{msg}: [#{current}] "
      value = gets.chomp
      valid = respond_to?(validate_method) ? send(validate_method, value) : true
    end
    @config[field] = value
    save_config
    value
  end

  def feedback(msg)
    puts msg
  end

  def err_feedback(msg)
    feedback("  ERROR: #{msg}")
  end

  def valid_source_repo?(value)
    @src_repo = begin
      Grit::Repo.new(value)
    rescue
      err_feedback("'#{value}' doesn't seem to be a git repo")
      nil
    end
  end

  def valid_destination_repo?(value)
    @dst_repo = Grit::Repo.init_bare_or_open(value)
    load_config(File.join(value, DEFAULT_CONFIG_NAME)) if @dst_repo
    @dst_repo
  end

  def collect_branches
    branches
  end

  def branches
    @src_branches ||= @src_repo.branches || []
  end

  def collect_users
    branches.each do |branch|
      name = branch.name
      num_commits = @src_repo.commit_count(name)
      (num_commits - 1).downto(0) do |idx|
        commit = @src_repo.commits(name, 1, idx)
        GitUser.user_for_commit(commit.first)
      end
    end
    @users = GitUser.users
    @config['users'] = @users
  end

  def verify_user_aliases

  end

  def collect_object_names

  end

  def verify_object_aliases

  end

  def copy_branch(branch)

  end

  def update_user_stats

  end
end

#GitAnon.new(ARGV[0]).anonymize

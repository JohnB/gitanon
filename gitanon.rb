require 'grit'
require 'yaml'

class GitAnon
  DEFAULT_CONFIG_NAME = ".gitanon"

  def initialize(filename = nil)
    load_config(filename)
  end

  def anonymize
    if valid_config?
      collect_branches
      collect_users
      verify_user_aliases
      collect_object_names
      verify_object_aliases
    else
      ask_for('source_repo')
      ask_for('destination_repo')
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
    @src_branches.each do |branch|
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
  end
  def save_config
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
    current = @config[field.to_s]
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
    @dst_repo = begin
      Grit::Repo.new(value)
    rescue
      err_feedback("'#{value}' doesn't seem to be a git repo")
      nil
    end
    load_config(File.join(value, DEFAULT_CONFIG_NAME)) if @dst_repo
  end

  def collect_branches
    @src_branches = @src_repo.branches
  end

  def collect_users

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

GitAnon.new(ARGV[0]).anonymize

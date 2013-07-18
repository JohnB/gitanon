require 'spec_helper'
require File.dirname(__FILE__) + '/../git_anon'

describe GitAnon do
  context "new" do
    it "should accept filename" do
      ga = GitAnon.new('spec/fixtures/empty.yml')
      ga.should be
      ga.config_filename.should =~ /empty.yml/
    end
    it "should accept a params hash" do
      params = {'source_repo' => '.'}
      ga = GitAnon.new(params)
      ga.should be
      ga.source_repo.should =~ /\./
    end
  end

  context "collect_users" do
    it "should not crash" do
      params = {'source_repo' => '.'}
      #params = {'source_repo' => '../grit'}
      ga = GitAnon.new(params)
      ga.should be
      lambda do
        ga.collect_users
      end.should_not raise_error
      ga.users.should be
    end
  end
end

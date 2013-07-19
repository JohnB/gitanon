require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../deluminator'

describe Deluminator do
  describe "new" do
    it "should not crash"
  end
  describe 'obfuscate' do
    before do
      @text = "
        # describe this method
        def so_something_useful(arg1,argn)
          argn.collect {|item| item * arg1 }
        end
      "
      @junk = Deluminator.new.obfuscate(@text)
    end
    it "should result in the same length of data" do
      @text.length.should == @junk.length
    end
    it "should have line breaks at the same positions" do
      text_lines = @text.split("\n")
      junk_lines = @junk.split("\n")
      text_lines.length.should == junk_lines.length.should
      text_lines.each_with_index do |str, idx|
        str.length.should == junk_lines[idx].length
      end
    end

    %w(def end collect).each do |keyword|
      it "should leave '#{keyword}' unchanged" do
        @junk.should =~ Regexp.new(keyword)
      end
    end
    %w(describe method this so_something_useful\( arg1 argn item).each do |sensitive_word|
      it "should replace '#{sensitive_word}' with gibberish" do
        @junk.should_not =~ Regexp.new(sensitive_word)
      end
    end
  end
end

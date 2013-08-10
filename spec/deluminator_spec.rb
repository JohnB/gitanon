require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../deluminator'

describe Deluminator do
  describe "new" do
    it "should not crash" do
      lambda {
        Deluminator.new
      }.should_not raise_error
    end
    it "should raise if it receives bad dictionary value" do
      lambda {
        Deluminator.new( {:length_indexed_dict => :not_a_hash} )
      }.should raise_error
    end
    it "should raise if it receives bad reserved value" do
      lambda {
        Deluminator.new( {:reserved => :not_an_array} )
      }.should raise_error
    end
    it "should populate the dictionary hash" do
      d = Deluminator.new( {:length_indexed_dict => {4 => {'fred' => 'glub'}}} )
      d.dictionary.is_a?(Hash).should == true
    end
    it "should populate the reserved hash" do
      d = Deluminator.new( {:reserved => %w(def class if else elsif end)} )
      d.reserved.is_a?(Array).should == true
      d.reserved.length.should == 6
    end
  end
  describe 'add_to_dictionary' do
    before do
      @deluminator = Deluminator.new( {:length_indexed_dict => {5 => {"hello" => "world"}}})
    end
    it "should increase the size of the dictionary when receiving new data" do
      @deluminator.dictionary.length.should == 1
      @deluminator.add_to_dictionary("fragile countenance")
      @deluminator.dictionary.length.should == 3
      @deluminator.dictionary["fragile"].should_not == "fragile"
      @deluminator.dictionary["countenance"].should_not == "countenance"
    end
    it "should not increase the size of the dictionary when receiving data it has seen before" do
      @deluminator.add_to_dictionary("happy dancer")
      size = @deluminator.dictionary.length
      @deluminator.add_to_dictionary("dancer happy")
      @deluminator.dictionary.length.should == size
    end
    it "should have definitions of the same length as the original word" do
      @deluminator.add_to_dictionary("friendly ghost")
      @deluminator.dictionary["friendly"].length.should == "friendly".length
      @deluminator.dictionary["ghost"].length.should == "ghost".length
    end
    it "should maintain the same case as the original word" do
      @deluminator.add_to_dictionary("asHJedLumP")
      result = @deluminator.dictionary["asHJedLumP"]
      result.should_not == nil
      result.each_char.each_with_index do |char,index|
        if [2,3,6,9].include?(index)
          ('A'..'Z').to_a.include?(result[index..index]).should == true
        else
          ('a'..'z').to_a.include?(result[index..index]).should == true
        end
      end

    end
    it "should not add too-short items to the dictionary"
  end
  #describe 'deluminate' do
  #  before do
  #    @text = "
  #      # describe do_something_useful here:
  #      # it bamboozles the ferlang without augmenting glerk!
  #      def do_something_useful(arg1,argn)
  #        argn.collect {|item| item * arg1 }
  #      end
  #    "
  #    @junk = Deluminator.new(@text).obfuscate
  #    @junk = @text
  #    puts @junk
  #  end
  #  it "should result in the same length of data" do
  #    @text.length.should == @junk.length
  #  end
  #  it "should have line breaks at the same positions" do
  #    text_lines = @text.split("\n")
  #    junk_lines = @junk.split("\n")
  #    text_lines.length.should == junk_lines.length.should
  #    text_lines.each_with_index do |str, idx|
  #      str.length.should == junk_lines[idx].length
  #    end
  #  end
  #
  #  %w(def end collect describe this).each do |keyword|
  #    it "should leave '#{keyword}' unchanged" do
  #      @junk.should =~ Regexp.new(keyword)
  #    end
  #  end
  #  %w(the x y dir el).each do |shortword|
  #    it "should leave short words like '#{shortword}' unchanged" do
  #      @junk.should =~ Regexp.new(shortword)
  #    end
  #  end
  #  %w(method do_something_useful arg1 argn item bamboozles ferlang without augmenting glerk).each do |sensitive_word|
  #    it "should replace '#{sensitive_word}' with gibberish" do
  #      @junk.should_not =~ Regexp.new(sensitive_word)
  #    end
  #  end
  #end
end

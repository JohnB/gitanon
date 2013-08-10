class Deluminator
  #KEYWORDS = %w(def end collect each class module open close inject select detect reject upto downto
  #              this self describe context it should
  #              )
  attr_reader :reserved

  MIN_DICTIONARY_LENGTH = 4
  UPVOWELS = %w(A E I O U Y)
  LOWVOWELS = %w(a e i o u y)
  UPPERS = ('A'..'Z').to_a - UPVOWELS
  LOWERS = ('a'..'z').to_a - LOWVOWELS
  VOWEL_LEN = UPVOWELS.length
  NONVOWEL_LEN = UPPERS.length

  def initialize(hash = {})
    @length_indexed_dict = hash[:length_indexed_dict] || {}
    @reserved   = hash[:reserved]   || []
    raise ":reserved value must be an array"   unless @reserved.is_a?(Array)
    raise ":length_indexed_dict value must be a hash" unless @length_indexed_dict.is_a?(Hash)
    raise ":length_indexed_dict keys must be integers" unless @length_indexed_dict.keys.all? { |k| k.is_a?(Integer) }
  end
  def add_to_dictionary(text)
    text.split(/\s+|[^a-zA-z]+/).each do |word|
      add_one_word_to_dictionary(word)
    end
  end

  # flattened hash of all our sub-hashes
  def dictionary
    hash = {}
    @length_indexed_dict.each do |len, words_of_same_length|
      hash.merge! words_of_same_length
    end
    hash
  end
  def deluminate(text)
  end

  private

  def add_one_word_to_dictionary(word)
    return word if word.nil? || word.length < MIN_DICTIONARY_LENGTH
    @length_indexed_dict[word.length] ||= {}
    return @length_indexed_dict[word.length][word] if @length_indexed_dict[word.length][word]

    result = transmute(word)
    existing = @length_indexed_dict[word.length].values
    while existing.include?(result) do
      result = result.next   # "aaaa".next=="aaab"
    end
    @length_indexed_dict[word.length][word] = result
    puts @length_indexed_dict.inspect
    @length_indexed_dict[word.length][word]
  end

  def transmute(word)
    word.split('').collect do |letter|
      if UPPERS.include?(letter)
        if UPVOWELS.include?(letter)
          UPVOWELS[rand(VOWEL_LEN)]
        else
          UPPERS[rand(NONVOWEL_LEN)]
        end
      else
        if LOWVOWELS.include?(letter)
          LOWVOWELS[rand(VOWEL_LEN)]
        else
          LOWERS[rand(NONVOWEL_LEN)]
        end
      end
    end.join
  end
end

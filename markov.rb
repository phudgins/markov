require 'active_support/core_ext/string'
class Markov

  attr_accessor :chain, :order, :max_words

  def initialize(order=2, max_words=24)
    self.order = order
    self.max_words = max_words
    self.chain = Hash.new { |h,k| h[k] = [] }
  end

  def populate_from_file(filename)
    str = File.open(filename, 'rb') { |f| f.read }
    str.squish!
    words = str.chars.select {|c| c.ord.chr.is_utf8? }.join("").split(/[\s()"]+/)
    words.each_with_index do |word, index|
      phrase = words[index, self.order] # current phrase
      self.chain[phrase] << words[index + self.order] # next possibility
    end
  end

  def generate_text
    phrase = self.chain.keys.sample
    output = []
    self.max_words.times do
      # grab all possibilities for our state
      options = self.chain[phrase]

      # add the first word to our output and discard
      output << phrase.shift

      # select at random and add it to our phrase
      phrase.push options.sample

      # the last phrase of the input text will map to an empty array of
      # possibilities so exit cleanly.
      break if phrase.compact.empty? # all out of words
    end
    output.join(' ')
  end

end

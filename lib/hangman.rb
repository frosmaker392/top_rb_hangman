require_relative 'console_input'

class Hangman
  include Input

  def initialize(dictionary_filename)
    @dict_filename = dictionary_filename
    @guesses = 6
  end

  public

  def start
    @word_arr = select_random_word.downcase.split('')
    @guess_arr = Array.new(@word_arr.length) { '_' }

    print_arr(@word_arr)
    print_arr(@guess_arr)
  end

  private

  def print_arr(arr)
    arr.each do |element|
      print "#{element} "
    end
    print "\n"
  end

  #Returns a random word of length 5-12 from the dictionary
  def select_random_word
    line_count = `wc -l "#{@dict_filename}"`.strip.split(' ')[0].to_i
  
    random_word = ""
    unless random_word.length > 4 && random_word.length < 13
      rand_line = rand(1..line_count)
      File.foreach(@dict_filename).with_index do |line, line_num|
        if line_num == rand_line
          random_word = line.chomp
          break
        end
      end
    end
  
    random_word
  end
end

hangman = Hangman.new('5desk.txt')
hangman.start
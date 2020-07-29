require_relative 'console_input'

class Hangman
  include Input

  def initialize(dictionary_filename)
    @dict_filename = dictionary_filename
  end

  public

  def start
    puts select_random_word
  end

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
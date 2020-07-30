require_relative 'console_input'

class Hangman
  include Input

  def initialize(dictionary_filename)
    @dict_filename = dictionary_filename
    @max_failed_guesses = 6
  end

  public

  def start
    @word_arr = select_random_word.downcase.split('')
    @guess_arr = Array.new(@word_arr.length) { '_' }
    @current_failed_guess = 0
    @won = false

    until @won || @current_failed_guess == @max_failed_guesses
      play_round
      @won = guess_complete?
    end

    if @won
      puts "Your guess was correct! Clap"
    else
      puts "Tough luck! The word was : "
      display_arr(@word_arr)
    end
  end

  private

  def play_round
    display_arr(@guess_arr)
    print "Enter your guess as an alphabet : "

    char = get_valid_input(lambda {|x| validate_char_input(x)}, "TRY ANOTHER : ")
    char_matches = check_and_show_char(char)

    @current_failed_guess += 1 unless char_matches
  end

  # Checks if char exists in @word, then swaps the '_' with char at the matching positions,
  # returns true if char exists in @word, otherwise false
  def check_and_show_char(char)
    found = false
    @word_arr.each_with_index do |w_char, w_index|
      if w_char == char
        found = true
        @guess_arr[w_index] = char
      end
    end
    
    found
  end

  # Returns true if guess is successfully filled (does not contain '_')
  def guess_complete?
    !@guess_arr.include?('_')
  end

  # Prints an array in space-separated format
  def display_arr(arr)
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

  def validate_char_input(input)
    input = input.downcase

    raise "Input is empty!" if input == ''
    raise "Input is not a single character!" if input.length > 1
    raise "Non-alphabetic character detected!" if !(input =~ /^-?[a-z]+$/)

    input
  end
end

hangman = Hangman.new('5desk.txt')
hangman.start
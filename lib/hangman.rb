require_relative 'console_input'

class Hangman
  include Input

  # dictionary_filename - path of word dictionary to be used, 
  # drawings_list_filename - path of a file containing the hangman drawings
  # after each failed guess, comma-separated
  def initialize(dictionary_filename, drawings_list_filename)
    @dict_filename = dictionary_filename
  
    drawings_list_file = File.open(drawings_list_filename)
    @drawings_arr = drawings_list_file.readlines(',')
    drawings_list_file.close

    # Remove the commas and add newlines to the end of each drawing
    @drawings_arr.map! do |drawing_txt|
      drawing_txt.gsub(',', '') + "\n"
    end

    @max_failed_guesses = @drawings_arr.length - 1
  end

  public

  # Starts a game of Hangman with 6 failed guesses as a fail condition
  def start
    @word_arr = select_random_word.downcase.split('')
    @guess_arr = Array.new(@word_arr.length) { '_' }

    @played_chars = []
    @current_failed_guess = 0
    @won = false

    print %(    ------- Hangman -------    
  How to play : 
 \> You will be shown an empty Hangman drawing and a string of empty spaces \(\'_\'\).
 \> On each guess, enter an alphabet which you guess is the letter the word contains.
 \> If your guess is correct then the next guess will reveal where the letter is in the string.
 \> Otherwise a part of the Hangman will be drawn.
 \> If you have #{@max_failed_guesses} wrong guesses then Hangman drawing should be complete and you lose.
 \> You win if you correctly guess all the letters before the drawing is finished.\n\n)

    until @won || @current_failed_guess == @max_failed_guesses
      print @drawings_arr[@current_failed_guess]

      play_round
      @won = guess_complete?
    end

    print @drawings_arr[@current_failed_guess]

    if @won
      display_arr(@word_arr)
      puts "Your guess was correct! Clap"
    else
      puts "Too bad! The word was : "
      display_arr(@word_arr)
    end
  end

  private

  # Plays a 'round' (a guess more or less)
  def play_round
    display_arr(@guess_arr)
    print "Enter your guess as an alphabet : "

    char = get_valid_input(lambda {|x| validate_char_input(x)}, "Enter an alphabet : ")
    char_matches = check_and_show_char(char)

    @played_chars << char
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

  # Validator function to return only valid alphabets
  def validate_char_input(input)
    input = input.downcase

    raise "Input is empty!" if input == ''
    raise "Input is not a single character!" if input.length > 1
    raise "Character was not an alphabet!" if !(input =~ /^-?[a-z]+$/)

    raise "You've played that character!" if @played_chars.include?(input)

    input
  end
end

hangman = Hangman.new('5desk.txt', 'hangman_txt_drawings.txt')
hangman.start
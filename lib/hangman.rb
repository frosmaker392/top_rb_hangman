require_relative 'console_input'
require_relative 'jsonable'

class HangmanData < JSONable
  attr_accessor :word_arr
  attr_accessor :guess_arr
  attr_accessor :current_failed_guess
  attr_accessor :played_chars

  def initialize(word_arr, guess_arr, cur_failed_guess, played_chars)
    @word_arr = word_arr
    @guess_arr = guess_arr
    @current_failed_guess = cur_failed_guess
    @played_chars = played_chars
  end
end

class Hangman
  include Input

  attr_reader :current_hm_data

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

  def init
    print %(    ------- Hangman -------    
  How to play : 
 \> You will be shown an empty Hangman drawing and a string of empty spaces \(\'_\'\).
 \> On each guess, enter an alphabet which you guess is the letter the word contains.
 \> If your guess is correct then the next guess will reveal where the letter is in the string.
 \> Otherwise a part of the Hangman will be drawn.
 \> If you have #{@max_failed_guesses} wrong guesses then Hangman drawing should be complete and you lose.
 \> You win if you correctly guess all the letters before the drawing is finished.
 \> Enter '!save' mid-game to save and quit.

-- Play a new game or load a save file : 
1. New Game     2. Load Game    3. Exit
Enter the corresponding number : )
    choice = get_valid_input(range_lambda(1..3))
    @current_hm_data = default_hm_data 

    if choice == 1
      start_game

    elsif choice == 2
      begin
        prompt_load
        puts "Save loaded!"
      rescue Exception => e
        puts e
        puts 'An error occured, making a new game instead.'
      ensure
        start_game
      end
    else
      exit(true)
    end
  end

  private

  def default_hm_data
    word_arr = select_random_word.downcase.split('')
    guess_arr = Array.new(word_arr.length) { '_' }

    current_failed_guess = 0
    played_chars = []

    HangmanData.new(word_arr, guess_arr, current_failed_guess, played_chars)
  end

  # Starts a game of Hangman with the current data
  def start_game
    @won = false

    until @won || @current_hm_data.current_failed_guess == @max_failed_guesses
      print @drawings_arr[@current_hm_data.current_failed_guess]

      play_round
      @won = guess_complete?
    end

    print @drawings_arr[@current_hm_data.current_failed_guess]

    if @won
      display_arr(@current_hm_data.word_arr)
      puts "Your guess was correct! Clap"
    else
      puts "Too bad! The word was : "
      display_arr(@current_hm_data.word_arr)
    end
  end

  # Plays a 'round' (a guess more or less)
  def play_round
    display_arr(@current_hm_data.guess_arr)
    print "Enter your guess as an alphabet : "

    char = get_valid_input(lambda {|x| validate_char_input(x)}, "Enter an alphabet : ")
    prompt_save if char == '!save'

    char_matches = check_and_show_char(char)

    @current_hm_data.played_chars << char
    @current_hm_data.current_failed_guess += 1 unless char_matches
  end

  def prompt_load
    savefiles_list = Dir['saves/*.json']

    raise "No savefiles found!" if savefiles_list.length == 0

    puts "Choose a savefile : "

    savefiles_list.each_with_index do |savefile, index|
      puts "#{index+1}. #{savefile[6..-6]}"
    end

    print "Enter the corresponding number : "
    selected_index = get_valid_input(range_lambda(1..savefiles_list.length)) - 1
    
    savefile_string = File.read(savefiles_list[selected_index])
    @current_hm_data.from_json!(savefile_string)
  end

  # Prompts for a save name, serializes the hm_data into a json then exits
  def prompt_save   
    print 'Enter a name for your save (alphanumeric only): '
    save_name = get_valid_input(lambda { |x| validate_alphanumeric(x) })
    save_file_path = "saves/#{save_name}.json"
    
    Dir.mkdir('saves') unless Dir.exists?('saves')
    File.open(save_file_path, 'w') do |file|
      file.write(@current_hm_data.to_json)
    end

    exit(true)
  end

  # Checks if char exists in @word, then swaps the '_' with char at the matching positions,
  # returns true if char exists in @word, otherwise false
  def check_and_show_char(char)
    found = false
    @current_hm_data.word_arr.each_with_index do |w_char, w_index|
      if w_char == char
        found = true
        @current_hm_data.guess_arr[w_index] = char
      end
    end
    
    found
  end

  

  # Returns true if guess is successfully filled (does not contain '_')
  def guess_complete?
    !@current_hm_data.guess_arr.include?('_')
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
    return input if input == '!save'

    input = input.downcase

    raise "Input is empty!" if input == ''
    raise "Input is not a single character!" if input.length > 1
    raise "Character was not an alphabet!" if !(input =~ /^-?[a-z]+$/)

    raise "You've played that character!" if @current_hm_data.played_chars.include?(input)

    input
  end

  def validate_alphanumeric(input)
    raise "Input is empty!" if input == ''
    raise "Some characters are not alphanumeric!" if !(input =~ /^-?[a-zA-Z0-9]+$/)

    input
  end
end

hangman = Hangman.new('5desk.txt', 'hangman_txt_drawings.txt')
hangman.init
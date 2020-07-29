def select_random_word
  line_count = `wc -l "5desk.txt"`.strip.split(' ')[0].to_i

  random_word = ""
  unless random_word.length > 4 && random_word.length < 13
    rand_line = rand(1..line_count)
    File.foreach("5desk.txt").with_index do |line, line_num|
      if line_num == rand_line
        random_word = line.chomp
        break
      end
    end
  end

  random_word
end

p select_random_word
module Input
  # Get user input and repeat prompt with try_again_msg 
  # if validator_lambda throws an exception with input
  def get_valid_input(validator_lambda, try_again_msg = nil)
    try_again_msg = "Try again : " if try_again_msg.nil?

    valid = false
    input = ""

    until valid
      input = gets.chomp
      begin
        input = validator_lambda.call(input)  
      rescue Exception => e
        puts e
        print try_again_msg
      else
        valid = true
      end
    end

    input
  end

  def range_lambda(range, err_msg = nil)
    err_msg = "Out of range!" if err_msg.nil?

    return lambda do |value|
      value.tr(' ', '')
      raise "Input is not a number!" if !(value =~ /^-?[0-9]+$/)
      raise err_msg if !(range.include?(value.to_i))

      value.to_i
    end
  end
end
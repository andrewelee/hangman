class Hangman

	def initialize(guessing_player, checking_player)
		@guessing_player = guessing_player
		@checking_player = checking_player
	end

	def play
		turn = 1
		max_turns = 10
		display_string = ""
		
		secret_word_length = @checking_player.pick_secret_word
		@checking_player.receive_secret_length(secret_word_length)
		display_string = "_" * secret_word_length

		until turn > max_turns
			puts "Turn: #{turn}/#{max_turns}"
			puts display_string

			guessed_letter = @guessing_player.guess(display_string)
			checker_response = @checking_player.check_guess(guessed_letter)
			@guessing_player.update(checker_response, guessed_letter)
			
			turn += 1 if checker_response == []

			checker_response.each do |position|
				display_string[position] = guessed_letter
			end

			if display_string.include?("_") == false
				puts "We have a winner!"
				puts "Word was: #{display_string}"
				return
			end 	

		end

		puts "Hangman - Gameover."
	end

end

class HumanPlayer

	def pick_secret_word
		puts "Enter a word length: "
		length = gets.chomp.to_i
	end

	def guess(string)
		puts "Please guess a letter:"
		player_guess = gets.chomp
	end

	def check_guess(guessed_letter)
		puts "Does your word have the letter: #{guessed_letter}?"
		answer = gets.chomp.downcase
		if answer == "yes" || answer == "y"
			puts "What positions?"
			positions = gets.chomp.split(",")
			return positions.map{|x| x.to_i - 1}
		else
			return []
		end
	end

	def receive_secret_length(length)
		puts "Secret word is #{length} letters long."
	end

	def update(positions, letter)
		if positions != []
			puts "It did have the letter: #{letter}"
		else
			puts "It didn't have the letter: #{letter}"
		end
	end


end

class ComputerPlayer
	attr_accessor :secret_word

	def initialize
		@dictionary = File.readlines("dictionary.txt").map! {|word| word.chomp}
		@guessed_letters = []
	end

	def pick_secret_word
		@secret_word = @dictionary.sample
		@secret_word.length
	end

	def check_guess(letter)
		
		letter_positions = []

		if @secret_word.include?(letter)
			secret_letters = @secret_word.split("")
			secret_letters.each_with_index do |sec_letter, index|
				letter_positions << index if sec_letter == letter
			end
		end

		letter_positions
	end

	#Computer guessing methods
	def receive_secret_length(length)
		@dictionary = @dictionary.select { |word| word.length == length}
	end

	def guess(string)
		p @dictionary.length
		abort("No words left in my dictionary. That or you're cheating.") if @dictionary.length == 0
		
		letter = generate_letters_hash
		@guessed_letters << letter
		letter

	end

	def generate_letters_hash
		letters = {}
		@dictionary.each do |word|
			word.each_char do |letter|
				letters[letter] = 0 unless letters.include?(letter)
        		letters[letter] += 1
        	end
        end

        @guessed_letters.each do |l|
			letters.delete(l) if letters.include?(l)
		end

        max = letters.values.max
       	letter = letters.key(max)
    end

    def update(positions, letter)
    	@dictionary = @dictionary.select {|word| valid_word?(word,positions,letter)}
    end

    def valid_word?(word, positions, letter)
    	
    	if positions == []
    		return false if word.include?(letter)
    	else

	    	return false unless word.include?(letter)

	    	letters = word.split("")

	    	letters.each_with_index do |let, index|
	    		return false if let == letter && !positions.include?(index)
	    	end
    	end
    	return true
    end
end

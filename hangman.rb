require "yaml"

class Hangman
    def initialize
        dictionary = File.readlines("dictionary.txt")
        dictionary = dictionary.select do |word|
            word.length >= 5 && word.length <=12
        end

        @word = dictionary[rand(0..dictionary.length)].chomp
        @incorrect_guesses = 0
        @correct_letters = []
        @incorrect_letters = []
    end

    def save_game
        puts "Enter a name for your save file: "
        name = gets.chomp
        while name == ""
            puts "The name cannot be a blank string."
            puts "Please enter a valid name"
            name = gets.chomp
        end
        filename = name + ".yml"
        File.open(filename, "w") do |file|
            file.write(self.to_yaml)
        end
        puts "Game saved."
        puts "Would you like to quit the game? (y/n)"
        answer = gets.chomp.downcase
        if answer.include? "y"
            exit
        end
    end

    def main
        while @incorrect_guesses < 6
            puts "Would you like to save the game? (y/n)"
            answer = gets.chomp.downcase
            if answer.include? "y"
                save_game
            end
            @word.each_char do |char|
                if @correct_letters.include? char
                    print char + " "
                else
                    print "_ "
                end
            end
            print "  Incorrect letters: " + @incorrect_letters.join(", ") if @incorrect_letters != []
            puts "\nEnter a letter: "
            letter = gets.chomp
            letter = letter.downcase
            while (@incorrect_letters.include? letter) || (@correct_letters.include? letter)
                puts "You already tried that letter. Please try a new one"
                letter = gets.chomp
                letter = letter.downcase
            end
            if @word.include? letter
                puts "Correct!"
                @correct_letters << letter
                if @correct_letters.sort == @word.split("").uniq.sort
                    puts "You win!"
                    return
                end
            else
                puts "Incorrect"
                @incorrect_guesses += 1
                @incorrect_letters << letter
            end
        end
        puts "The correct word was " + @word
    end

    def self.main
        puts "Welcome to hangman!"
        puts %q(
        Would you like to:
            1. start a new game, or
            2. Load a game?
        )
        answer = gets.chomp
        if answer == "1"
            game = self.new
            game.main
        else
            games = Dir.glob("*.yml")
            if games.length == 0
                puts "There are no saved games to load"
                puts "Would you like to start a new game? (y/n)"
                answer = gets.chomp.downcase
                while !["y", "n"].include? answer
                    puts "Please enter either (y)es or (n)o"
                    answer = gets.chomp.downcase
                end
                if answer.include? "y"
                    game = self.new
                    game.main
                else
                    puts "Goodbye!"
                    exit
                end
            else
                game_names = games.collect do |game|
                    game.split(".")[0]
                end
                puts "Which of the following games would you like to open?"
                game_names.each_with_index do |game, index|
                    puts "\t" + (index + 1).to_s + ": " + game
                end
                answer = gets.chomp.to_i - 1
                if (answer < 0) || (answer > games.length)
                    puts "Please enter a number between 1 and #{games.length}"
                    puts "Which of the following games would you like to open?"
                    game_names.each_with_index do |game, index|
                        puts "\t" + (index + 1).to_s + ": " + game
                    end
                    answer = gets.chomp.to_i - 1
                end
                game = YAML.load_file(games[answer])
                game.main
            end
        end
    end
end

Hangman.main

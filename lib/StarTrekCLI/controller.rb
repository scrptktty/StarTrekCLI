require "pry"

class StarTrekCLI::Controller

  def initialize
     # NYI: something.new
  end

  def call
    puts "Welcome to StarTrekCLI!"

    help
    list_series

    loop do
      puts "What series would you like to see?"
      command = gets.strip.downcase.to_sym

      case command
      when :exit
        break
      when :help
        help
      when :"list series"
        list_series
      else
        puts "Does not compute, please try again."
      end
    end
  end # Controller#call

  def help
    puts "To list all of the Star Trek series, enter 'list series'."
    puts "To quit, type 'exit'."
  end

  def list_series
    StarTrekCLI::Series.all.each do |series|
      puts "#{series.name}"
    end
  end

end # StarTrekCLI::StarTrekController
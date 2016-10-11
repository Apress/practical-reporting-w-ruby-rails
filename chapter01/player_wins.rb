require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'root',  # This is the default username and password
  :password => '',      # for MySQL, but note that if you have a
                        # different username and password,
                        # you should change it.
  :database => 'players_2')


class Player <  ActiveRecord::Base
	has_many :wins
  def total_wins
    total_wins = 0
    self.wins.each do |win|
    total_wins = total_wins + win.quantity
    end
    total_wins
  end
end
class Game <  ActiveRecord::Base
	has_many :wins
end
class Win <  ActiveRecord::Base
	belongs_to :game
  belongs_to :player
end

games = Game.find(:all)

games.each do |game|
  highest_win=nil
  game.wins.each do |win|
  highest_win = win if highest_win.nil? or 
                                   win.quantity > highest_win.quantity
  end

  puts "#{game.name}: #{highest_win.player.name} with #{highest_win.quantity} wins"
end

players = Player.find(:all) 

highest_winning_player = nil

players.each do |player|
  highest_winning_player = player if 
                    highest_winning_player.nil? or 
                    player.total_wins > highest_winning_player.total_wins
end

puts "Highest Winning Player: #{highest_winning_player.name} with #{highest_winning_player.total_wins} wins"


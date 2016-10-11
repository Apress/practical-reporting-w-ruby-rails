require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'root',  # This is the default username and password
  :password => '',      # for MySQL, but note that if you have a
                        # different username and password,
                        # you should change it.
  :database => 'players')


class Player <  ActiveRecord::Base
end

Player.delete_all

Player.new do |p|
  p.name = "Matthew 'm_giff' Gifford"
  p.salary = 89000.00
  p.wins = 11
  p.save
end

Player.new do |p|
  p.name = "Matthew 'Iron Helix' Bouley"
  p.salary = 75000.00
  p.wins  = 4
  p.save
end

Player.new do |p|
  p.name = "Luke 'Cable Boy' Bouley"
  p.salary = 75000.50
  p.wins = 7
  p.save
end

salary_total = 0
win_total=0

players = Player.find(:all) 
players.each do |player|
  puts "#{player.name}: $#{'%0.2f' % (player.salary/player.wins)} per win"
  salary_total = salary_total + player.salary
  win_total = win_total + player.wins
end

puts "\nAverage Cost Per Win : $#{'%0.2f' % (salary_total / win_total )}"


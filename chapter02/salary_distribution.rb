require 'active_record'

# Establish a connection to the database...
ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'root',  # This is the default username and password
  :password => '',      # for MySQL, but note that if you have a
                        # different username and password,
                        # you should change it.
  :database => 'players_3')

# ... set up our models ...
class Player <  ActiveRecord::Base
  has_many :wins
end
class Game <  ActiveRecord::Base
  has_many :wins
end	
class Win <  ActiveRecord::Base
  belongs_to :game
  belongs_to :player
end

# ... and perform our calculation: 

puts "Salary\t\tCount"

Player.calculate(:count, :id, :group=>'salary').each do |player|
  salary, count = *player
  puts "$#{'%0.2f' % salary}\t#{count} "

  # Note that the '%0.25f' % call formats the value as a float 
  # with two decimal points; the String's % operator works
  # similarly to the C sprintf function.

end


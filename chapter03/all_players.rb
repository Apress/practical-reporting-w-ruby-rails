require 'gruff'
require 'active_record'

game_id_to_analyze = 5

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'your_mysql_username_here',    
  :password => 'your_mysql_password_here',      
  :database => 'players_4')


class Player <  ActiveRecord::Base
  has_many :wins
end

class Game <  ActiveRecord::Base
  has_many :wins
end

class Play <  ActiveRecord::Base
  belongs_to :game
  belongs_to :player
end

class Event < ActiveRecord::Base
  belongs_to :play
end

def puts_underlined(text, underline_char="=")
  puts text
  puts underline_char * text.length
end

pic_dir='./all_players_graph_pics'
Dir.mkdir(pic_dir) unless File.exists?(pic_dir)

line_chart = Gruff::Line.new(1024)
index=0
columns = {}
Event.find(:all, :group=>'event DESC').each do |e| 
  columns[index] = e.event
  index=index+1
end

line_chart.labels = columns
line_chart.legend_font_size = 10
line_chart.legend_box_size = 10
line_chart.title = "Chart of All Players"
line_chart.minimum_value = 0
line_chart.maximum_value = 110

Player.find(:all).each do |player|
  total_games = Play.count(:conditions=>['game_id = ? AND player_id = ?',
                           game_id_to_analyze, player.id]).to_f
  total_wins = Play.count(:conditions=>['game_id = ? AND player_id = ? AND won=1',
                           game_id_to_analyze, player.id]).to_f
    
 sql = "SELECT event, avg(time) as average_time

          FROM events as e
                INNER JOIN
               plays as p
                 ON e.play_id=p.id
         WHERE p.game_id='#{game_id_to_analyze}'
                 AND
               p.player_id='#{player.id}'
         GROUP 
            BY e.event DESC;"
  data = []
  Event.find_by_sql(sql).each do |row|
    data << (row.average_time.to_i/1000)  
  end

  line_chart.data(player.name, data  )
  
end

line_chart.write("all_players.png")


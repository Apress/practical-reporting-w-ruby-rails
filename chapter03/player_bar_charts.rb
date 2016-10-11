require 'gruff'
require 'active_record'

game_id_to_analyze = 5

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'root',  # This is the default username and password
  :password => '',      # for MySQL, but note that if you have a
                        # different username and password,
                        # you should change it.
  :database => 'players_4')


class Player <  ActiveRecord::Base
  has_many :plays
end

class Game <  ActiveRecord::Base
  has_many :plays
end

class Play <  ActiveRecord::Base
  belongs_to :game
  belongs_to :player
end

class Event < ActiveRecord::Base
  belongs_to :plays
end

columns = Event.find(:all, :group=>'event DESC')
pic_dir='./player_graph_pics' #Used to store the graph pictures.
Dir.mkdir(pic_dir) unless File.exists?(pic_dir)

Player.find(:all).each do |player|
  bar_chart = Gruff::Bar.new(1024)
  bar_chart.legend_font_size = 12
  total_games = Play.count(:conditions=>['game_id = ? ' <<
                                         'AND player_id = ?', 

                                          game_id_to_analyze, 
                                          player.id]).to_f

  total_wins = Play.count(:conditions=>['game_id = ? ' << 
                                        'AND player_id = ? ' << 
                                        'AND won=1', 

                                         game_id_to_analyze, 
                                         player.id]).to_f
  
  win_ratio = (total_wins / total_games * 100).to_i unless total_games == 0
  win_ratio ||= 0
  bar_chart.title = "#{player.name} " <<
                    "(#{win_ratio}% won)"
  bar_chart.minimum_value = 0
  bar_chart.maximum_value = 110
    
  sql = "SELECT event, AVG(time) as average_time

           FROM events AS e
                  INNER JOIN
                plays AS p
                  ON e.play_id=p.id
          WHERE p.game_id='#{game_id_to_analyze}'
                  AND
                p.player_id='#{player.id}'
          GROUP 
             BY e.event DESC;"
  data = []
  Event.find_by_sql(sql).each do |row|
    bar_chart.data row.event, (row.average_time.to_i/1000)  
  end
  bar_chart.labels = {0=>'Time'}
  bar_chart.write("#{pic_dir}/player_#{player.id}.png")
end


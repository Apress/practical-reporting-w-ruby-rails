require 'fox16'
require 'active_record'
require 'optparse'
require 'rubygems'
require 'gruff'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'insert_your_mysql_username_here',  
  :password => 'insert_your_mysql_password_here',     
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


include Fox

class ParagonGraphWindow 
    def initialize

        @main_window=FXMainWindow.new(get_app, 
                            "Paragon Studios Player Reporting Software", 
                            nil, nil, DECOR_ALL )
        @main_window.width=640; @main_window.height=480

        control_matrix=FXMatrix.new(@main_window,4, MATRIX_BY_COLUMNS)

        FXLabel.new(control_matrix, 'Game:')
        @game_combobox = FXComboBox.new(control_matrix, 30, nil, 
                                        COMBOBOX_STATIC | FRAME_SUNKEN  )
        @game_combobox.numVisible = 5
        @game_combobox.editable = false
        
        Game.find(:all).each do |game|
          @game_combobox.appendItem(game.name , game.id)
        end
        @game_combobox.connect(SEL_COMMAND) do 
          update_display
        end

        FXLabel.new(control_matrix, 'Player:')

        @player_combobox = FXComboBox.new(control_matrix, 35, nil,  
                                          COMBOBOX_STATIC | FRAME_SUNKEN  )
        @player_combobox.numVisible = 5
        @player_combobox.editable = false

        Player.find(:all).each do |player|
          @player_combobox.appendItem(player.name , player.id)
        end

        @player_combobox.connect(SEL_COMMAND) do 
          update_display
        end

        @graph_picture_viewer = FXImageView.new(@main_window , nil, nil, 0, 
                                                LAYOUT_FILL_X | LAYOUT_FILL_Y)
         
        @graph_picture_viewer.connect( SEL_CONFIGURE ) do 
          update_display
        end

        @main_window.show( PLACEMENT_SCREEN )
    end
    def update_display
      game_id_to_analyze = @game_combobox.getItemData(@game_combobox.currentItem)
      player = Player.find(@player_combobox.getItemData(
                                             @player_combobox.currentItem))
      bar_chart = Gruff::Bar.new("#{@graph_picture_viewer.width}x" <<
                                 "#{@graph_picture_viewer.height}")
      bar_chart.legend_font_size = 12
      total_games = Play.count(:conditions=>['game_id = ? AND ' <<
                                             'player_id = ?', 
                                             game_id_to_analyze, player.id]
                               ).to_f || 0
      total_wins = Play.count(:conditions=>['game_id = ? AND ' <<
                                            'player_id = ? AND won=1', 
                                             game_id_to_analyze, player.id]
                              ).to_f || 0
      
      bar_chart.title = "#{player.name} (#{'%i' % (total_games==0 ? '0' : (total_wins/total_games * 100))}% won)" 
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
          GROUP BY e.event DESC;"
      data = []
      Event.find_by_sql(sql).each do |row|
        bar_chart.data row.event, (row.average_time.to_i/1000)  
      end
      bar_chart.labels = {0=>'Time'}
      chart_png_filename = "./player_#{player.id}.png"
      bar_chart.write(chart_png_filename)

      pic = FXPNGImage.new(FXApp.instance())

      FXFileStream.open(chart_png_filename, 
                        FXStreamLoad) { |stream| pic.loadPixels(stream) }

      pic.create
      @graph_picture_viewer.image = pic
      File.unlink(chart_png_filename)

    end
    
end

fox_application=FXApp.new

ParagonGraphWindow.new

FXApp.instance().create # Note that getApp returns the same FXApp instance
                # as fox_application references.

FXApp.instance().run


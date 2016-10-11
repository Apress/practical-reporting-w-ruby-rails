require 'active_record'
require 'optparse'
require 'rubygems'
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

require 'spreadsheet/excel'
include Spreadsheet
spreadsheet_file = "spreadsheet_report.xls"
workbook = Excel.new(spreadsheet_file)
worksheet = workbook.add_worksheet


page_header_format = Format.new(:color=>'black', :bold=>true, :size=>30)
player_name_format = Format.new(:color=>'black', :bold=>true)
header_format      = Format.new(:color=>'gray',  :bold=>true)
data_format        = Format.new()

workbook.add_format(page_header_format)
workbook.add_format(player_name_format)
workbook.add_format(header_format)
workbook.add_format(data_format)

worksheet.format_column(0, 35, data_format)

current_row=0

worksheet.write(current_row, 0, 'Player Win/Loss Report', page_header_format)

current_row=current_row+1

Player.find(:all).each do |player|

  worksheet.format_row(current_row, current_row==1 ? 20 : 33, player_name_format)  
  worksheet.write(current_row, 0, player.name)
  current_row=current_row+1

  worksheet.write(current_row, 0, ['Game', 'Wins', 'Losses'], header_format)
  current_row=current_row+1


  Game.find(:all).each do |game|

    win_count = Play.count(:conditions=>[
                 "player_id = ? AND
                  game_id= ? AND
                  won=true",

                  player.id, 
                  game.id])

    loss_count = Play.count(:conditions=>[
                 "player_id = ? AND
                  game_id= ? AND
                  won=false",

                  player.id, 
                  game.id])

    worksheet.write(current_row, 0, [game.name, win_count, loss_count])
    current_row=current_row+1
  end

end

workbook.close


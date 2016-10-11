class PerformanceController < ApplicationController
  def show
    @player = Player.find_by_id(params[:player_id])
    @game = Game.find_by_id(params[:game_id])

    @events = Event.find(:all,
                   :select=>'event, ' <<
                            'AVG(time)/1000 as average_time',
                   :group=>'events.event DESC',
                   :joins=>' INNER JOIN plays ON events.play_id=plays.id', 
                   :conditions=>["plays.game_id = ? AND plays.player_id= ?", 
                                 @game.id, @player.id]
                        ).map { |event|
                          {:event=>event.event, 
                           :average_time=>event.average_time.to_i}
                              }


      respond_to do |format|
        format.html { render :layout=>false if request.xhr? }
        format.text { render :layout=>false }
        format.xml { render :xml=>{'player'=>@player, 
                                   'game'=>@game,
                                   'events'=>@events
                                  }.to_xml(:root=>'player_performance_report', 
                                           :skip_types=>true)  }
        format.json { render :json=>{'player'=>@player, 
                                    'game'=>@game,
                                    'events'=>@events}.to_json }
      end
    
  end
end

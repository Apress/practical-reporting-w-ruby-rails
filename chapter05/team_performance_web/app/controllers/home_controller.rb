class HomeController < ApplicationController
  def index
    @available_players =Player.find(:all)
    @available_games = Game.find(:all)
  end
end

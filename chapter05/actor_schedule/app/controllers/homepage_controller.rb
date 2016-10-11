class HomepageController < ApplicationController
  def index
    @actors_today = []
    @actors_tommorow = []
    Actor.find(:all).each do |actor|
      @actors_today << {:actor=>actor, :bookings=>actor.booking.find(:all, :conditions=>['TO_DAYS(booked_at)=TO_DAYS(NOW())'])}
      @actors_tommorow << {:actor=>actor, :bookings=>actor.booking.find(:all, :conditions=>['TO_DAYS(booked_at)=TO_DAYS(NOW())+1'])}
    end
  end
end

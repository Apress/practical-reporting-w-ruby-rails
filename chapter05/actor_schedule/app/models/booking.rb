class Booking < ActiveRecord::Base
  belongs_to :actor
  belongs_to :project
  belongs_to :room
end

class Grade < ActiveRecord::Base
  belongs_to :salesperson
  belongs_to :training_class
end

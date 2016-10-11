class Salesperson < ActiveRecord::Base
  has_many :grade
  #has_many :passing_grade, :class=>:grade, :conditions=>'percentage_grade>80', :group=>'class'
end

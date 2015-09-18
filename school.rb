class School < ActiveRecord::Base

  has_many :courses, through: :terms
  has_many :terms

  default_scope { order('name') }
end

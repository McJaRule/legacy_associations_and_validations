class School < ActiveRecord::Base
  has_many :terms
  validates :name, presence: true

  has_many :courses, through: :terms
  has_many :terms

  default_scope { order('name') }

  def add_term(term)
    terms << term
  end

end

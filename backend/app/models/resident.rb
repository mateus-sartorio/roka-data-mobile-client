class Resident < ApplicationRecord
  has_many :collect, dependent: :destroy

  def as_json(options = {})
    super(include: :collect)
  end
end
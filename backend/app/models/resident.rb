class Resident < ApplicationRecord
  has_many :collect, dependent: :destroy

  has_many :receipts
  has_many :currency_handouts, through: :receipts

  def as_json(options = {})
    super(include: :collect)
  end
end
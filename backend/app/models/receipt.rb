class Receipt < ApplicationRecord
  belongs_to :resident
  belongs_to :currency_handout
end

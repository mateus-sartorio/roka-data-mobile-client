class CurrencyHandout < ApplicationRecord
    has_many :receipts
    has_many :residents, through: :receipts
end

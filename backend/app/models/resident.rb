class Resident < ApplicationRecord
    has_many :collect, dependent: :destroy
end
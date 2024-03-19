json.extract! receipt, :id, :handout_date, :value, :resident_id, :currency_handout_id, :created_at, :updated_at
json.url receipt_url(receipt, format: :json)

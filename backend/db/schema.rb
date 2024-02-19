# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_02_19_023718) do
  create_table "residents", force: :cascade do |t|
    t.string "name"
    t.integer "situation"
    t.integer "roka_id"
    t.boolean "has_plaque"
    t.integer "registration_year"
    t.string "address"
    t.string "reference_point"
    t.boolean "lives_in_JN"
    t.string "phone"
    t.boolean "is_on_whatsapp_group"
    t.date "birthdate"
    t.string "profession"
    t.integer "residents_in_the_house"
    t.string "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

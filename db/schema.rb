# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170615164704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alerts", ["user_id"], name: "index_alerts_on_user_id", using: :btree

  create_table "cmm_callbacks", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pa_request_id"
  end

  add_index "cmm_callbacks", ["pa_request_id"], name: "index_cmm_callbacks_on_pa_request_id", using: :btree

  create_table "credentials", force: :cascade do |t|
    t.integer "user_id"
    t.string  "fax",     limit: 255
  end

  add_index "credentials", ["user_id"], name: "index_credentials_on_user_id", using: :btree

  create_table "pa_requests", force: :cascade do |t|
    t.integer  "prescription_id"
    t.boolean  "urgent"
    t.string   "form_id",               limit: 255
    t.string   "state",                 limit: 255
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cmm_token",             limit: 255
    t.string   "cmm_link",              limit: 255
    t.string   "cmm_id",                limit: 255
    t.string   "cmm_workflow_status",   limit: 255
    t.text     "request_pages_actions"
    t.string   "cmm_outcome",           limit: 255
    t.integer  "prescriber_id"
    t.string   "form_name",             limit: 255, default: "None Chosen"
    t.boolean  "display",                           default: true
    t.boolean  "is_retrospective",                  default: false
  end

  add_index "pa_requests", ["prescription_id"], name: "index_pa_requests_on_prescription_id", using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.string   "date_of_birth", limit: 255
    t.string   "state",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street_1",      limit: 255
    t.string   "street_2",      limit: 255
    t.string   "city",          limit: 255
    t.string   "zip",           limit: 255
    t.string   "phone_number",  limit: 255
    t.string   "gender",        limit: 255
    t.string   "email",         limit: 255
    t.string   "bin",           limit: 255
    t.string   "pcn",           limit: 255
    t.string   "group_id",      limit: 255
    t.string   "member_id"
  end

  create_table "pharmacies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "street",     limit: 255
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "fax",        limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip",        limit: 255
  end

  create_table "prescriptions", force: :cascade do |t|
    t.string   "drug_number",         limit: 255
    t.integer  "quantity",                        default: 1
    t.string   "frequency",           limit: 255
    t.integer  "refills"
    t.boolean  "dispense_as_written"
    t.integer  "patient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "drug_name",           limit: 255
    t.datetime "date_prescribed"
    t.boolean  "active"
    t.integer  "pharmacy_id"
    t.boolean  "pa_required",                     default: false
    t.boolean  "autostart",                       default: false
  end

  add_index "prescriptions", ["patient_id"], name: "index_prescriptions_on_patient_id", using: :btree
  add_index "prescriptions", ["pharmacy_id"], name: "index_prescriptions_on_pharmacy_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string "description", limit: 255, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",            limit: 255
    t.string   "npi",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name",             limit: 255
    t.integer  "role_id"
    t.string   "email",                 limit: 255
    t.string   "practice_name",         limit: 255
    t.string   "practice_phone_number", limit: 255
    t.string   "practice_street_1",     limit: 255
    t.string   "practice_street_2",     limit: 255
    t.string   "practice_city",         limit: 255
    t.string   "practice_state",        limit: 255
    t.string   "practice_zip",          limit: 255
    t.boolean  "registered_with_cmm",               default: false
  end

  add_index "users", ["npi"], name: "index_users_on_npi", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120408194026) do

  create_table "failures", :force => true do |t|
    t.integer  "fallible_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "fallibles", :force => true do |t|
    t.string   "kind"
    t.string   "env"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "human_replies", :force => true do |t|
    t.integer  "fallible_id"
    t.string   "from"
    t.string   "to"
    t.datetime "sent_at"
    t.text     "body"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "settings", :force => true do |t|
    t.string "key"
    t.text   "value"
  end

  create_table "shard_bodies", :force => true do |t|
    t.integer  "failure_id"
    t.string   "shard"
    t.text     "body"
    t.datetime "last_failed_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end

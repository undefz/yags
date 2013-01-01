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

ActiveRecord::Schema.define(:version => 20121229174438) do

  create_table "authors", :force => true do |t|
    t.string   "nickname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contributions", :force => true do |t|
    t.integer  "author_id"
    t.integer  "repo_id"
    t.integer  "lines_added"
    t.integer  "lines_deleted"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "contributions", ["author_id"], :name => "index_contributions_on_author_id"
  add_index "contributions", ["repo_id"], :name => "index_contributions_on_repo_id"

  create_table "repos", :force => true do |t|
    t.string   "name"
    t.string   "last_commit"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
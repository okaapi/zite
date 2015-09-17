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

ActiveRecord::Schema.define(version: 20150916012017) do

  create_table "pages", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "user_id"
    t.string   "visibility",  default: "any"
    t.string   "editability", default: "editor"
    t.string   "menu",        default: "true"
    t.string   "lock",        default: "false"
    t.string   "editor",      default: "wysiwyg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",        default: "localhost"
    t.string   "meta_desc"
  end

  create_table "site_maps", force: true do |t|
    t.string   "external"
    t.string   "internal"
    t.string   "aux"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_actions", force: true do |t|
    t.integer  "user_session_id"
    t.string   "controller"
    t.string   "action"
    t.string   "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",            default: "localhost"
  end

  add_index "user_actions", ["user_session_id"], name: "index_user_actions_on_user_session_id", using: :btree

  create_table "user_sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "client"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",       default: "localhost"
  end

  add_index "user_sessions", ["user_id"], name: "index_user_sessions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "alternate_email", default: ""
    t.string   "password_digest"
    t.string   "token"
    t.string   "role",            default: "user"
    t.string   "active",          default: "unconfirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",            default: "localhost"
  end

end

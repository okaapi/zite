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

  create_table "pages", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "content",     limit: 65535
    t.integer  "user_id",     limit: 4
    t.string   "visibility",  limit: 255,   default: "any"
    t.string   "editability", limit: 255,   default: "editor"
    t.string   "menu",        limit: 255,   default: "true"
    t.string   "lock",        limit: 255,   default: "false"
    t.string   "editor",      limit: 255,   default: "wysiwyg"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "site",        limit: 255,   default: "localhost"
    t.string   "meta_desc",   limit: 255
  end

  create_table "site_maps", force: :cascade do |t|
    t.string   "external",   limit: 255
    t.string   "internal",   limit: 255
    t.string   "aux",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_actions", force: :cascade do |t|
    t.integer  "user_session_id", limit: 4
    t.string   "controller",      limit: 255
    t.string   "action",          limit: 255
    t.string   "params",          limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "site",            limit: 255, default: "localhost"
  end

  add_index "user_actions", ["user_session_id"], name: "index_user_actions_on_user_session_id", using: :btree

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "client",     limit: 255
    t.string   "ip",         limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "site",       limit: 255, default: "localhost"
  end

  add_index "user_sessions", ["user_id"], name: "index_user_sessions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255
    t.string   "email",           limit: 255
    t.string   "alternate_email", limit: 255, default: ""
    t.string   "password_digest", limit: 255
    t.string   "token",           limit: 255
    t.string   "role",            limit: 255, default: "user"
    t.string   "active",          limit: 255, default: "unconfirmed"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "site",            limit: 255, default: "localhost"
  end

end

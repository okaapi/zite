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

ActiveRecord::Schema.define(version: 2018_05_01_022722) do

  create_table "alexas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "intent"
    t.string "slot"
    t.string "aux"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "skill"
  end

  create_table "pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.integer "user_id"
    t.string "visibility", default: "any"
    t.string "editability", default: "editor"
    t.string "menu", default: "true"
    t.string "lock", default: "false"
    t.string "editor", default: "wysiwyg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "site", default: "localhost"
    t.string "meta_desc"
  end

  create_table "site_maps", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "external"
    t.string "internal"
    t.string "aux"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_session_id"
    t.string "controller"
    t.string "action"
    t.string "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "site", default: "localhost"
    t.index ["user_session_id"], name: "index_user_actions_on_user_session_id"
  end

  create_table "user_sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "client"
    t.string "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "site", default: "localhost"
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "alternate_email", default: ""
    t.string "password_digest"
    t.string "token"
    t.string "role", default: "user"
    t.string "active", default: "unconfirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "site", default: "localhost"
  end

end

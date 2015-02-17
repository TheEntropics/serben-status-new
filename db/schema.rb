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

ActiveRecord::Schema.define(version: 20150217162208) do

	create_table "logs", force: true do |t|
		t.integer "level"
		t.string "title"
		t.text "message"
		t.datetime "created_at"
		t.datetime "updated_at"
	end

	create_table "pings", force: true do |t|
		t.boolean "up"
		t.integer "ping"
		t.datetime "created_at"
		t.datetime "updated_at"
	end

	create_table "services", force: true do |t|
		t.string "service"
		t.boolean "status"
		t.datetime "created_at"
		t.datetime "updated_at"
	end

	create_table "sys_infos", force: true do |t|
		t.float "cpu"
		t.float "ram"
		t.datetime "uptime"
		t.datetime "created_at"
		t.datetime "updated_at"
	end

end

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

ActiveRecord::Schema[8.0].define(version: 2025_09_29_065413) do
  create_table "badges", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "icon_class"
    t.text "criteria"
    t.integer "points_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.text "prerequisites"
    t.integer "xp_reward"
    t.integer "required_level"
    t.integer "position"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "category"
    t.string "difficulty"
    t.integer "estimated_duration"
    t.text "learning_objectives"
    t.boolean "practice_trade_enabled"
  end

  create_table "portfolios", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "portfolio_type"
    t.decimal "total_value", precision: 15, scale: 2
    t.decimal "initial_value", precision: 15, scale: 2
    t.decimal "risk_score", precision: 3, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "portfolio_type"], name: "index_portfolios_on_user_id_and_portfolio_type"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.decimal "current_price", precision: 10, scale: 2
    t.datetime "last_updated"
    t.string "sector"
    t.bigint "market_cap"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sector"], name: "index_stocks_on_sector"
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
  end

  create_table "trades", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "symbol"
    t.decimal "entry_price", precision: 10, scale: 2
    t.decimal "exit_price", precision: 10, scale: 2
    t.decimal "stop_loss", precision: 10, scale: 2
    t.decimal "position_size", precision: 10, scale: 2
    t.integer "quantity"
    t.decimal "pnl", precision: 10, scale: 2
    t.string "status"
    t.datetime "entry_date"
    t.datetime "exit_date"
    t.integer "lesson_id"
    t.text "market_view"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_trades_on_lesson_id"
    t.index ["status"], name: "index_trades_on_status"
    t.index ["symbol"], name: "index_trades_on_symbol"
    t.index ["user_id", "created_at"], name: "index_trades_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "user_badges", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "badge_id", null: false
    t.datetime "earned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "user_lessons", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lesson_id", null: false
    t.datetime "completed_at"
    t.integer "xp_earned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_user_lessons_on_lesson_id"
    t.index ["user_id"], name: "index_user_lessons_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "experience_points"
    t.integer "level"
    t.integer "current_streak"
    t.integer "total_trades"
    t.integer "profitable_trades"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "portfolios", "users"
  add_foreign_key "trades", "lessons"
  add_foreign_key "trades", "users"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
  add_foreign_key "user_lessons", "lessons"
  add_foreign_key "user_lessons", "users"
end

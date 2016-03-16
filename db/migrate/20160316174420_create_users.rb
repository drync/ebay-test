class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :auth_token, null: false, limit: 2048
    end
  end
end

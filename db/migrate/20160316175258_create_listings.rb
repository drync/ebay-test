class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :user_id, null: false
      t.string  :name, null: false
      t.string  :ebay_uid, null: false
    end
  end
end

class AddSkuToListings < ActiveRecord::Migration
  def change
    add_column :listings, :sku, :string
  end
end

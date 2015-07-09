class AddActiveToAddresses < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :active, :boolean, :default => true
    Spree::Address.reset_column_information
    Spree::Address.update_all(:active => true)

    add_index :spree_addresses, :active
  end
end

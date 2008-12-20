class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, :password_type, :password_hash, :salt, :first_name, :last_name, :email, :phone_number
      t.boolean :has_picked, :has_been_picked, :is_admin, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

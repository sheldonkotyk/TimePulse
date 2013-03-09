class ConvertUsersTableToDevise < ActiveRecord::Migration
  class UserSession < Authlogic::Session::Base
  end
  class ConversionUser < ActiveRecord::Base
     set_table_name "users"
     acts_as_authentic do |c|
        c.session_class = UserSession
    end
  end
  
  def up

    add_column :users,  :encrypted_password, :string

    ConversionUser.find(:all).each do |u|
        du = User.find(u.id)
        password = u.password
        du.password = password
        du.password_confirmation = password
        du.save
    end

    add_column :users, :confirmation_token, :string, :limit => 255
    add_column :users, :confirmed_at, :timestamp
    add_column :users, :confirmation_sent_at, :timestamp
    execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at"
    add_column :users, :reset_password_token, :string, :limit => 255
    add_column :users, :reset_password_sent_at, :timestamp
    add_column :users, :remember_token, :string, :limit => 255
    add_column :users, :remember_created_at, :timestamp
    rename_column :users, :login_count, :sign_in_count
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip

    rename_column :users, :failed_login_count, :failed_attempts
    add_column :users, :unlock_token, :string, :limit => 255
    add_column :users, :locked_at, :timestamp

    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :single_access_token

    add_index :users, :email,                :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :unlock_token,         :unique => true
  end

  def down
  end
end

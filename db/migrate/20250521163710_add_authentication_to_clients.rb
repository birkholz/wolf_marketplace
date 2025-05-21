class AddAuthenticationToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :email, :string
    add_column :clients, :password_digest, :string
    add_index :clients, :email, unique: true
  end
end

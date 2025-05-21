class AddIndexToClientsName < ActiveRecord::Migration[7.0]
  def change
    add_index :clients, :name
  end
end

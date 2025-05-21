class AddClientIdToOpportunities < ActiveRecord::Migration[8.0]
  def change
    add_reference :opportunities, :client, null: false, foreign_key: true
  end
end

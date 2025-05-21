class CreateOpportunities < ActiveRecord::Migration[8.0]
  def change
    create_table :opportunities do |t|
      t.string :title
      t.string :description
      t.integer :salary

      t.timestamps
    end
  end
end

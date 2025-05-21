class AddNameToJobSeekers < ActiveRecord::Migration[8.0]
  def change
    add_column :job_seekers, :name, :string
  end
end

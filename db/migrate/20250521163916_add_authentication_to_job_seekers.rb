class AddAuthenticationToJobSeekers < ActiveRecord::Migration[8.0]
  def change
    add_column :job_seekers, :email, :string
    add_column :job_seekers, :password_digest, :string
    add_index :job_seekers, :email, unique: true
  end
end

class AddCompoundIndexForOpportunitySearch < ActiveRecord::Migration[8.0]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm'

    # Add GIN indices for ILIKE searches
    execute 'CREATE INDEX index_opportunities_title_trgm ON opportunities USING gin (title gin_trgm_ops)'
    execute 'CREATE INDEX index_opportunities_description_trgm ON opportunities USING gin (description gin_trgm_ops)'
    execute 'CREATE INDEX index_clients_name_trgm ON clients USING gin (name gin_trgm_ops)'
  end

  def down
    execute 'DROP INDEX IF EXISTS index_opportunities_title_trgm'
    execute 'DROP INDEX IF EXISTS index_opportunities_description_trgm'
    execute 'DROP INDEX IF EXISTS index_clients_name_trgm'
  end
end

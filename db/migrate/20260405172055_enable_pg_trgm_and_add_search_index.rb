class EnablePgTrgmAndAddSearchIndex < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pg_trgm"

    # GIN trigram indexes for fast fuzzy search on title and description
    execute <<~SQL
      CREATE INDEX listings_title_trgm_idx ON listings USING GIN (title gin_trgm_ops);
      CREATE INDEX listings_description_trgm_idx ON listings USING GIN (description gin_trgm_ops);
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX IF EXISTS listings_title_trgm_idx;
      DROP INDEX IF EXISTS listings_description_trgm_idx;
    SQL

    disable_extension "pg_trgm"
  end
end

class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.references :author
      t.references :repo

      t.timestamps
    end
    add_index :contributions, :author_id
    add_index :contributions, :repo_id
  end
end

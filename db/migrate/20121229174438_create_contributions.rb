class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.belongs_to :author
      t.belongs_to :repo

      t.integer :lines_added
      t.integer :lines_deleted

      t.timestamps
    end
    add_index :contributions, :author_id
    add_index :contributions, :repo_id
  end
end

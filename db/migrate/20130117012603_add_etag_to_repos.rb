class AddEtagToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :etag, :string
  end
end

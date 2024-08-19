class AddUserIdToFeeds < ActiveRecord::Migration[7.1]
  def change
    add_column :feeds, :user_id, :integer
  end
end

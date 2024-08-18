class CreateFeeds < ActiveRecord::Migration[7.1]
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :source
      t.boolean :favorite

      t.timestamps
    end
  end
end

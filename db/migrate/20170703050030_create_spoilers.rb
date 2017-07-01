class CreateSpoilers < ActiveRecord::Migration[5.1]
  def change
    create_table :spoilers do |t|
      t.string :author
      t.string :channel_id
      t.string :team_domain
      t.text   :text
      t.timestamps null: false
    end
  end
end

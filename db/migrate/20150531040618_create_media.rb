class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :url
      t.references :event, index: true

      t.timestamps
    end
  end
end
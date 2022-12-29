class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :source
      t.string :url, null: false
      t.string :description
      t.integer :citations_amount
      t.string :date
      
      t.index :url, unique: true

      t.timestamps
    end
  end
end

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :source
      t.string :url unique: true
      t.string :description
      t.integer :citations_amount
      t.string :date

      t.timestamps
    end
  end
end

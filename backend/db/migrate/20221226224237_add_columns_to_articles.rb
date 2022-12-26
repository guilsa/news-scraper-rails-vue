class AddColumnsToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :source, :string
    add_column :articles, :citations, :string
    add_column :articles, :citations_amount, :integer
    add_column :articles, :date, :string
  end
end

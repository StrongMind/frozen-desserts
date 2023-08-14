class AddColorToDessert < ActiveRecord::Migration[7.0]
  def change
    add_column :desserts, :color, :string
  end
end

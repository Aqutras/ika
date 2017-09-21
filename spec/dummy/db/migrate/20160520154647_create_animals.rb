class CreateAnimals < ActiveRecord::Migration[5.1]
  def change
    create_table :animals do |t|
      t.string :type

      t.timestamps null: false
    end
  end
end

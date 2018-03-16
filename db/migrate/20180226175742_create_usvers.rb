class CreateUsvers < ActiveRecord::Migration[5.1]
  def change
    create_table :usvers do |t|

      t.string :name
      t.string :sex

      t.timestamps
    end
  end
end

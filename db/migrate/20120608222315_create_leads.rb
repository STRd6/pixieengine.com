class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.string :product, :null => false
      t.string :email, :null => false
      t.string :data
      t.timestamps :null => false
    end
  end
end

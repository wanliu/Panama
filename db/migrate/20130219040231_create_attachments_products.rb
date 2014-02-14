class CreateAttachmentsProducts < ActiveRecord::Migration
  def change
    create_table :attachments_products do |t|
      t.integer :attachment_id
      t.integer :product_id

      t.timestamps
    end
  end
end

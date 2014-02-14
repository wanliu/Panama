class CreateAskBuyAttachments < ActiveRecord::Migration
  def change
    create_table :ask_buys_attachments do |t|
      t.integer :ask_buy_id
      t.integer :attachment_id

      t.timestamps
    end
  end
end

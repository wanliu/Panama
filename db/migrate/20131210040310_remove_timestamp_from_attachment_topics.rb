class RemoveTimestampFromAttachmentTopics < ActiveRecord::Migration
  def up
    remove_timestamps :activities_order_transactions
    remove_timestamps :ask_buys_attachments
    remove_timestamps :attachments_products
    remove_timestamps :categories_properties
    remove_timestamps :attachments_chat_messages
    remove_timestamps :products_properties
    remove_timestamps :product_items_properties
    remove_timestamps :product_items_property_items
    remove_timestamps :attachments_regions
    remove_timestamps :attachments_topics
  end

  def down
    add_timestamps :activities_order_transactions
    add_timestamps :ask_buys_attachments
    add_timestamps :attachments_products
    add_timestamps :categories_properties
    add_timestamps :attachments_chat_messages
    add_timestamps :products_properties
    add_timestamps :product_items_properties
    add_timestamps :product_items_property_items
    add_timestamps :attachments_regions
    add_timestamps :attachments_topics
  end
end

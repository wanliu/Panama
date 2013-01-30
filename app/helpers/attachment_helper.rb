module AttachmentHelper

  def shop_attachments_upload
    shop_admins_attachments_upload(current_shop)
  end
end
module ProductsHelper

  def dispose_options(product)
    attachments = product.fetch(:attachment_ids, {})
    {:attachment_ids => attachments.map{|k, v| v} }
  end
end

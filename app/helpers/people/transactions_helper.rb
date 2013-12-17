module People
  module TransactionsHelper

    @@toolbars = []

    def transaction_path(people, record)
      if record.new_record?
        person_transactions_path(people.login)
      else
        person_transaction_path(people.login, record)
      end
    end

    def state_toolbar(&block)
      @@toolbars.push block
    end

    def render_toolbar
      @@toolbars.each do |toolbar|
        toolbar.call
      end
    end

    def render_funcat(template, options = {})
      options = {
        :partial => "people/transactions/funcat/#{template}",

      }.merge(options)
      render options
    end

    def buyer_state(state)
      I18n.t("order_states.buyer.#{state}")
    end

    def seller_state(state)
      I18n.t("order_states.seller.#{state}")
    end

    def shop_link(shop, options = {})
      link_to shop.name, shop_path(shop), options
    end

    def shop_image_link(shop, options = {})
      link_to shop_path(shop), options do
        image_tag(shop.photos.icon)
      end
    end
  end
end
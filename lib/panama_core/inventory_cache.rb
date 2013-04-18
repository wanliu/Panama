module PanamaCore
  module InventoryCache
    extend ActiveSupport::Concern

    def inventory
      @inventory = ::InventoryCache.where("product_id = ?", id)
                                   .order("last_time DESC")
                                   .first_or_create(:product_id => id, :count => 0, :last_time => Time.now.to_f)

      time = @inventory.last_time + 0.0001

      addition_quantity = ItemInOut
        .where("product_id = ? and created_at >= ?", id, Time.at(time))
        .sum("quantity") || 0

      @inventory = if addition_quantity != 0
        ::InventoryCache.create(:product_id => id,
                              :count => @inventory.count + addition_quantity,
                              :last_time => Time.now.to_f)
      else
        @inventory
      end

      @inventory.count
    end

    module ClassMethods

      def inventories(*args)
        find_by_sql(simple_product_inventory_sql(*args))
      end

      def item_in_outs_sql(*args)
        <<-SQL
          SELECT Item.id, Item.product_id, Item.options, Item.warehouse_id, Item.quantity, Item.updated_at, IC.last_time, IC.count
            FROM item_in_outs AS Item
            LEFT JOIN inventory_caches AS IC
              ON IC.product_id = Item.product_id
            ORDER BY IC.last_time DESC
        SQL
      end

      def product_inventory_cache_sql(*args)
        <<-SQL
          SELECT I.id, I.product_id, I.options, I.warehouse_id, I.created_at, Sum(IF(I.updated_at > FROM_UNIXTIME(R.last_time), I.quantity, 0)) As count, I.updated_at, FROM_UNIXTIME(R.last_time) AS last_time, R.count AS based
            FROM item_in_outs AS I
            LEFT JOIN ( #{item_in_outs_sql} ) AS R
              ON I.id = R.id
            GROUP BY I.product_id
        SQL
      end

      def product_inventory_sql(*args)
        options = args.extract_options!
        conditions = options.delete(:conditions) || {}
        conditions_string = conditions.blank? ? "" : "WHERE " + sanitize_sql_for_conditions(conditions)
        <<-SQL
          SELECT P.id, P.name, P.price, IR.options, IR.warehouse_id, IR.updated_at AS total_time, IR.count, IR.last_time, IR.based, (count + based) AS total
            FROM products AS P
            LEFT JOIN  ( #{product_inventory_cache_sql} ) AS IR
              ON P.id = IR.product_id
            #{conditions_string}
        SQL
      end

      def simple_product_inventory_sql(options = {}, include_options = false)
        conditions = options.delete(:conditions) || {}
        conditions_string = conditions.blank? ? "" : "WHERE " + sanitize_sql_for_conditions(conditions)

        include_options_string = include_options ? ", IIO.options" : ""
        <<-SQL
          SELECT P.id, P.name, P.price, IIO.options, IIO.warehouse_id, Sum(IIO.quantity) as total, IIO.updated_at
            FROM products AS P
            LEFT JOIN item_in_outs AS IIO
            ON P.id = IIO.product_id
            #{conditions_string}
            GROUP BY P.id #{include_options_string}
        SQL
      end
    end
  end
end
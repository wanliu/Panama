#encoding: utf-8
require "csv"

namespace :product do
  desc "load some product data"
  task :load_produt_items => :environment do
    Product.delete_all
    ProductItem.delete_all

    # FIXME 临时构造商品子数据，待分类数据完善后移除此操作
    products = ['帆布鞋', '跑鞋', '板鞋', '篮球鞋'].map do |name|
        product = Product.create(name: name, price: 50.0)
        product.update_attribute('shop_id', Shop.last.id)
        product.update_attribute('category_id', Category.last.id)
        product
    end

    products.each do |item|
        colour_style = item.styles.create(name: 'colours')
        [ {value: '#FFB6C1', title: '浅粉红', checked: true}, {value: '#FFC0CB', title: '粉红', checked: true},
        {value: '#7B68EE', title: '中板岩蓝', checked: true}, {value: '#00FA9A', title: '中春绿', checked: true}].each do |style|
            colour_style.items.create(style)
        end

        size_style = item.styles.create(name: 'sizes')
        [ {title: 'M', value: 'M', checked: true }, {title: 'ML', value: 'ML', checked: true}, {title: 'L', value: 'L', checked: true},
        {title: 'XL', value: 'XL', checked: true}, {title: 'XXL', value: 'XXL', checked: true}, {title: 'XXXL', value: 'XXXL', checked: true} ].each do |style|
                size_style.items.create(style)
        end

        price = rand(500..1000)
        colour_style.items.each do |color|
            size_style.items.each do |size|
                quantity = rand(10..20)
                sub = item.sub_products.create(price: price, quantity: quantity)
                sub.items << color
                sub.items << size
                sub.save
                puts "errors! #{sub.errors}" unless sub.valid?
            end
        end
    end
  end

  desc "export csv product data"
  task :load => :environment do
    CSV.foreach("#{Rails.root}/config/data/product_niu_nai.csv") do |row|
      category = Category.find_by(:name => "#{row[1]}粉")
      if category.nil?
        puts "===========not exists category: #{row.join('|')} "
      else
        duan = row[4]
        duan = "#{duan}段" unless duan.nil?
        Product.create(
          :name => "#{row[0]}#{row[2]}#{duan}#{row[3]}g",
          :price => 0,
          :brand_name => row[0],
          :category_id => category.id)
      end
    end
  end

end
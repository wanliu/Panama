# encoding: utf-8
require 'spec_helper'

describe Product do

  it "样式的关联 是 style_groups" do
    should have_many(:styles)
  end

  describe "methods that create subs and styles" do
  	let(:category) { Category.root }
  	let(:shop) { Shop.where(name: 'shop_for_style_items').first_or_create }
  	let(:product) { Product.where(name: 'iphone4s',
                                price: 5999,
                                category_id: category.id,
                                shop_id: shop.id).first_or_create }

  	let(:colours) { { "0" => {title: "浅粉红", checked: "浅粉红", value: "#FFB6C1" },
                      "1" => {title: "粉红", checked: "粉红", value: "#FFC0CB" } }.symbolize_keys }
  	let(:sizes)   { { "0" => {title: "M", value: "M" },
  				            "3" => {title: "XL", checked: "XL", value: "XL"}}.symbolize_keys }
  	let(:style)   { { "colours" => colours, "sizes" => sizes }.symbolize_keys }
  	let(:sub_products) { { "1" => { size: "XL", colour: "浅粉红", price: "55", quantity: "6"},
  									       "2" => { size: "XL", colour: "粉红", price: "55", quantity: "2" } }.symbolize_keys }
  	let(:params)  { { "style" => style, "sub_products" => sub_products }.symbolize_keys }

    before(:each) do
      product.styles.clear
      product.sub_products.clear
    end

    describe "updata_style_subs and create_style_subs" do
      it "updata should call create method, which will call create_style and create_subs method" do
        product.should_receive(:create_style).with(style)
        product.should_receive(:create_subs).with(sub_products)

        product.updata_style_subs(params)
      end
    end

    describe "create_style" do
      it "this create_style method should add two styel_groups" do
        expect { product.create_style(style) }.to change { product.styles.size }.from(0).to(2)
      end

      it "this create_style method should add four style_items" do
        expect { product.create_style(style) }.to change { StyleItem.all.size }.by(4)
      end
    end

    describe "create_subs" do
      before(:each) { product.create_style(style) }

      it "should invoke create_sub 2 times" do
        product.should_receive(:create_sub).exactly(2).times
        product.create_subs(sub_products)
      end

      it "should create 2 sub_products" do
        expect { product.create_subs(sub_products) }.to change { product.sub_products.size }.from(0).to(2)
      end

      it "should create 4 sytle_pairs which build the has_many through relationship" do
        expect { product.create_subs(sub_products) }.to change { StylePair.all.size }.by(4)
      end
    end

    describe "subs_back_for_edit" do
      it "should return params[:sub_products]" do
        back = product.subs_back_for_edit(params)
        back.should eql(sub_products)
      end
    end

    describe "sytles_back_for_edit" do
      it "should return changed style" do
        expect = style.map { |name, items| { 'name' => name, 'items' => items.values } }
        back = product.sytles_back_for_edit(params)
        back.should eql(expect)
      end
    end

  end
end

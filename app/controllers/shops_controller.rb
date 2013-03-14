#encoding: utf-8
require 'tempfile'
require 'fileutils'

class ShopsController < ApplicationController
  before_filter :login_required, :only => [:show_invite, :agree_invite, :show_email_invite]

  include Apotomo::Rails::ControllerMethods

  has_widgets do |root|
    root << widget(:navigator, :shop => @shop)
  end

  respond_to :erb

  admin

  layout 'shops'

  # GET /shops
  # GET /shops.json
  def index
    @shops = Shop.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shops }
    end
  end

  # GET /shops/1
  # GET /shops/1.json

  def show
    @shop = Shop.find_by(:name => params[:id])

    respond_to do |format|
      format.html { render_shop_content @shop, :index, @shop }
      format.json { render json: @shop }
    end
  end

  # GET /shops/new
  # GET /shops/new.json
  def new
    @shop = Shop.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shop }
    end
  end

  # GET /shops/1/edit
  def edit
    @shop = Shop.find_by(:name => params[:id])
  end

  # POST /shops
  # POST /shops.json
  def create
    @shop = Shop.new(params[:shop])
    @shop.user_id = current_user.id
    respond_to do |format|
      if @shop.save
        format.html { redirect_to @shop, notice: 'Shop was successfully created.' }
        format.json { render json: @shop, status: :created, location: @shop }
      else
        format.html { render action: "new" }
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shops/1
  # PUT /shops/1.json
  def update
    @shop = Shop.find_by(:name => params[:id])

    respond_to do |format|
      if @shop.update_attributes(params[:shop])
        format.html { redirect_to @shop, notice: 'Shop was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    @shop = Shop.find_by(:name => params[:id])
    @shop.destroy

    respond_to do |format|
      format.html { redirect_to shops_url }
      format.json { head :no_content }
    end
  end

  protected
  def content_tpl_path
    Rails.root.join "tmp/templates"
  end

  def generate_template(content, options = {})
    tpl = Tempfile.new(['shop', '.html.erb'], content_tpl_path.to_s)
    tpl.write(content)
    tpl.close
    tpl_name = tpl.path.gsub(/^(.*?)\.html\.erb/, '\1')
    begin
      yield(tpl_name, options)
    ensure
      tpl.unlink
    end
  end

  def render_shop_content(shop, name, *opts)
    content = shop.lookup_content(name)
    begin
      tpl = shop.fs[content.template].read
      generate_template(tpl) do |tpl_name, options|
        prepend_tpl_view_path
        inital = extract_temp_options opts
        render_content_template tpl_name, inital
      end
    rescue Vfs::Error => e
      raise "template file :#{content.template} not found"
    end
  end

  def render_content_template(tpl_file, inital = {})
    render tpl_file
  end

  def prepend_tpl_view_path
    tmpdir = Rails.root.join(content_tpl_path)
    FileUtils.mkdir_p tmpdir
    prepend_view_path tmpdir
  end

  def extract_temp_options(*args)
    args.last
  end

  private
end

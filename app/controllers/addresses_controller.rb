class AddressesController < ApplicationController

  layout 'shops'
   
  # GET /address/new
  # GET /address/new.json
  def new
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @address }
    end
  end
 

  # POST /address
  # POST /address.json
  def create
    @address = Address.new(params[:address])

    respond_to do |format|
      if @address.save
        format.html { redirect_to @address, notice: 'Shop was successfully created.' }
        format.json { render json: @address, status: :created, location: @address }
      else 
        format.html { render action: "new" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end
 
end

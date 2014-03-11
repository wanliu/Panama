class CityController < ApplicationController

  def index
    respond_to do |format|
        format.html
        format.json { head :no_content }
    end
  end


  def province
    @province = City.where(:ancestry=>City.roots[0].id.to_s)
    respond_to do |format|
        format.html
        format.json { render json: @province}
    end
  end

  # GET /city/1
  # GET /city/1.json
  def show
    @city =  City.find(params[:id]).children if params[:id]

    respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @city }
    end
  end
end

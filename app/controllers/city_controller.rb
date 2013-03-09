class CityController < ApplicationController

    def index

    end

    # GET /city/1
    # GET /city/1.json
    def show
        @city =  City.find(params[:id]).children

        respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @city }
        end
    end
end

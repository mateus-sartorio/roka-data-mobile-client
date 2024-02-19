class ResidentsController < ApplicationController
  def index
    residents = Resident.all
    render json: residents
  end
end

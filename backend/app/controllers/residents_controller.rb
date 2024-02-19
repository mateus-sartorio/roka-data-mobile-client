class ResidentsController < ApplicationController
  def index
    residents = Resident.all
    render json: residents
  end

  def create
    @resident = Resident.new(resident_params)

    if @resident.save
      render json: @resident, status: :created
    else
      render json: @resident.errors, status: :unprocessable_entity
    end
  end

  private
  def resident_params
    params.require(:resident).permit!
  end
end
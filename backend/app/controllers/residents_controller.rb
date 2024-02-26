class ResidentsController < ApplicationController
  def index
    residents = Resident.all
    render json: residents
  end

  def show
    resident = Resident.find(params[:id])
    render json: resident
  end

  def create
    resident = Resident.new(resident_params)

    if resident.save
      render json: resident, status: :created
    else
      render json: resident.errors, status: :unprocessable_entity
    end
  end

  def update
    resident = Resident.find(params[:id])

    if resident.update(resident_params)
      render json: resident, status: :ok
    else
      render json: resident.errors, status: :unprocessable_entity
    end
  end

  def destroy
    resident = Resident.find(params[:id])
    
    if resident.destroy
      render json: { message: "Resident successfully deleted" }, status: :ok
    else
      render json: { error: "Failed to delete resident" }, status: :unprocessable_entity
    end
  end

  private
  def resident_params
    params.require(:resident).permit!
  end
end
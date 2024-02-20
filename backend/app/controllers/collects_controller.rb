class CollectsController < ApplicationController
  def index
    collects = Collect.all
    render json: collects
  end

  def show
    collect = Collect.find(params[:id])
    render json: collect
  end

  def create
    collect = Collect.new(collect_params)

    if collect.save
      render json: collect, status: :created
    else
      render json: collect.errors, status: :unprocessable_entity
    end
  end
    
  def update
    collect = Collect.find(params[:id])

    if collect.update(collect_params)
      render json: collect, status: :ok
    else
      render json: collect.errors, status: :unprocessable_entity
    end
  end
    
  def destroy
    collect = Collect.find(params[:id])

    puts collect.name

    if collect.destroy
      render json: { message: "Collect successfully deleted" }, status: :ok
    else
      render json: { error: "Failed to delete collect" }, status: :unprocessable_entity
    end
  end

  private
  def collect_params
    params.require(:collect).permit!
  end
end

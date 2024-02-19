class CollectsController < ApplicationController
    def index
        collects = Collect.all
        render json: collects
    end

    def create
        @collect = Collect.new(collect_params)

        if @collect.save
            render json: @collect, status: :created
        else
            render json: @collect.errors, status: :unprocessable_entity
        end
    end

    private
    def collect_params
        params.require(:collect).permit!
    end
end

class CurrencyHandoutsController < ApplicationController
  before_action :set_currency_handout, only: %i[ show edit update destroy ]

  # GET /currency_handouts or /currency_handouts.json
  def index
    @currency_handouts = CurrencyHandout.all
  end

  # GET /currency_handouts/1 or /currency_handouts/1.json
  def show
  end

  # GET /currency_handouts/new
  def new
    @currency_handout = CurrencyHandout.new
  end

  # GET /currency_handouts/1/edit
  def edit
  end

  # POST /currency_handouts or /currency_handouts.json
  def create
    @currency_handout = CurrencyHandout.new(currency_handout_params)

    respond_to do |format|
      if @currency_handout.save
        format.html { redirect_to currency_handout_url(@currency_handout), notice: "Currency handout was successfully created." }
        format.json { render :show, status: :created, location: @currency_handout }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @currency_handout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /currency_handouts/1 or /currency_handouts/1.json
  def update
    respond_to do |format|
      if @currency_handout.update(currency_handout_params)
        format.html { redirect_to currency_handout_url(@currency_handout), notice: "Currency handout was successfully updated." }
        format.json { render :show, status: :ok, location: @currency_handout }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @currency_handout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /currency_handouts/1 or /currency_handouts/1.json
  def destroy
    @currency_handout.destroy

    respond_to do |format|
      format.html { redirect_to currency_handouts_url, notice: "Currency handout was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_currency_handout
      @currency_handout = CurrencyHandout.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def currency_handout_params
      params.require(:currency_handout).permit(:id, :title, :start_date)
    end
end

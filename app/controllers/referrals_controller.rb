class ReferralsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_referral, only: [:show, :edit, :update, :destroy]

  def index
    @referrals = Referral.viewable_by(current_user)
  end

  def show
    unless @referral.viewable_by?(current_user)
      flash[:alert] = "You do not have permission to view this referral."
      redirect_to no_permission_path # or wherever you want
    end
  end

  def new
    @referral = Referral.new
  end

  def create
    @referral = Referral.new(referral_params)
    if @referral.save
      redirect_to referrals_path
    else
      render :new
    end
  end


  def update
    # Rails.logger.debug("Initial params position: #{params[:referral][:position]}")
    Rails.logger.debug("Received Params: #{params.inspect}")
    Rails.logger.debug("Position before save: #{@referral.position}")


    if @referral.update(referral_params)

    Rails.logger.debug("Position after save: #{@referral.position}")

      # Check if referral_attributes are provided and if code and details are both empty
      if referral_params.keys == ["position"]
        # If only position is updated, respond differently
        head :ok
      end

    else
      Rails.logger.debug("Update failed: #{@referral.errors.full_messages}")
    end
  end

  private

  def referral_params
    params.require(:referral).permit(:position, :list_id)
  end

  def set_referral
    @referral = Referral.find(params[:id])
  end
end

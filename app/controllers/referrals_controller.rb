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

  private

  def referral_params
    params.require(:referral).permit(:name, :email, :phone, :message)
  end

  def set_referral
    @referral = Referral.find(params[:id])
  end
end

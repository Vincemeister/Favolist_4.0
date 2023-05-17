class ReferralsController < ApplicationController
  before_action :set_referral, only: [:show, :edit, :update, :destroy]

  def index
    @referrals = Referral.all
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

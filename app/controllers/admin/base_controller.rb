class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "Access denied. You are not authorized to view this page."
  end
end

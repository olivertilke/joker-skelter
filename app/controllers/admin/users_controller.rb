class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(created_at: :desc)
    @total_users = @users.count
    @new_users_today = User.where("created_at >= ?", Time.zone.now.beginning_of_day).count
    @total_jokes = Joke.count
    @total_chats = Chat.count
  end

  def destroy
    @user = User.find(params[:id])

    if @user == current_user
      redirect_to admin_users_path, alert: "You can't delete yourself, you absolute donut. 🍩"
      return
    end

    @user.destroy
    redirect_to admin_users_path, notice: "User #{@user.email} has been obliterated. 💀"
  end
end

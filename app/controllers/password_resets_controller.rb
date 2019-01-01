class PasswordResetsController < ApplicationController
  before_action :get_user, only:[:edit, :update]
  before_action :valid_user, only:[:edit,:update]
  before_action :check_expiration, only:[:edit,:update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  
  end

  def update
    if params[:user][:password].empty? # から文字パスワードを許容しない
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params) # パスワードを更新する
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit' # パスワードが更新できなかった場合
    end
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # フォームで扱うユーザーを設定する
    def get_user
      @user = User.find_by(email:params[:email])
    end

    # 存在しないユーザー、有効化されていないユーザー、不正なトークンの場合はリダイレクトする
    def valid_user
      unless(@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンの有効期限を確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :user_icon, :saved, :follower, :following]
  before_action :not_logged_in, only: [:edit, :update, :show, :saved, :follower, :following]
  before_action :logged_in, only: [:new, :confirm, :create]
  before_action :defferent_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def confirm
    @user = User.new(user_params)
    render :new if @user.invalid?
  end

  def create
    @user = User.new(user_params)
    if params[:back]
      render :new
    else
      if @user.save
        session[:user_id] = @user.id
        redirect_to entries_path
      else
        render 'new'
      end
    end
  end

  def edit

  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user.id)
    else
      render :edit
    end
  end

  def show
    @images = Entry.where(user_id: @user.id).order(created_at: :desc)
  end

  def saved
    @images = @user.my_bookmarks.order(created_at: :desc)
  end

  def follower
    @users = @user.followers
  end

  def following
    @users = @user.following
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :user_name, :password,
                                 :user_image, :user_image_cache)
  end

  def set_user
    @user = User.find(params[:id])
  end
end

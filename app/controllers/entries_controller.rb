class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy, :not_your_entry]
  before_action :not_logged_in
  before_action :not_your_entry, only: [:edit, :update, :destroy]

  def index
    ids = current_user.following.map{ |user| user.id }.push(current_user.id)
    @entries = Entry.where(user_id: ids).order(created_at: :desc)
    # binding.irb

    # @entries = Entry.order(created_at: :desc)
    @all_reply = Reply.all
    @reply = Reply.new
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = current_user.entries.build(entry_params)
    # @entry = Entry.new(entry_params)
    # @entry.user_id = current_user.id
    # この2行が上記になる
    if params[:back]
      render :new
    else
      if @entry.save
        ContactMailer.contact_mail(@entry).deliver
        redirect_to entries_path
      else
        render 'new'
      end
    end
  end

  def show
    @replies = Reply.where(entry_id: @entry.id)
    @reply = Reply.new
  end

  def edit

  end

  def update
    if @entry.update(entry_params)
      redirect_to entries_path
    else
      render :edit
    end
  end

  def destroy
    @entry.destroy
    redirect_to entries_path
  end

  def confirm
    @entry = current_user.entries.build(entry_params)
    # @entry = Entry.new(entry_params)
    # @entry.user_id = current_user.id
    # この2行が上記になる
    render :new if @entry.invalid?
  end

  private

  def entry_params
    params.require(:entry).permit(:image, :image_cache, :content)
  end

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def not_your_entry
    unless current_user.id == @entry.user_id
      redirect_to entries_path
    end
  end
end

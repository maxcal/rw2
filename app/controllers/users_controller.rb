# This provides addional actions for users in addition to [Devise::Registrations]
# for example adding and removing roles from users.
class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_user, except: [:index]

  # GET /users/:id
  def show
    @title = @user.nickname
    @available_roles =  Role.all.to_a.keep_if do |role|
      !@user.has_role?(role.name.to_sym)
    end
  end

  # GET /users/
  def index
    @title = "Users"
    @users = User.all
  end

  # DESTROY /users/:id
  def destroy
    if @user == current_user
      return redirect_to users_path, flash: { alert: "You cannot delete your own accout!" }
    end

    @user.destroy!
    redirect_to users_path, flash: { success: "User deleted." }
  end

  # GET /users/:id/edit
  def edit
    Role::AVAILABLE_ROLES.each do |role|
      # This adds an unsaved role to the user if it does not exist
      @user.roles.build(name: role) unless @user.has_role?(role)
    end
  end

  # PATCH /users/:id
  def update
    if @user.update(update_params)
      redirect_to @user, notice: 'User updated.'
    else
      render :edit
    end
  end

  private

    def set_user
      @user = User.friendly.find(params[:id])
      authorize @user
    end

    def update_params
      params.require(:user).permit(:email, role_ids: [])
    end
end

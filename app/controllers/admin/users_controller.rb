  
module Admin

	class UsersController < ApplicationController
	
	  before_action :set_user, only: [:show, :edit, :update, :destroy]
	  before_action :only_if_admin
	      
	  # GET /users
	  # GET /users.json
	  def index
	    @users = User.all  
	  end
	
	  # GET /users/1
	  # GET /users/1.json
	  def show
	  end
	
	  # GET /users/new
	  def new
	    @user = User.new
	    @user.alternate_email = nil
	  end
	
	  # GET /users/1/edit
	  def edit
	  end
	
	  def role_change
	    @user = User.by_id( params[:id] )
	    @user.change_role( params[:role] )
	    redirect_to action: :index
	  end
	  
	  # POST /users
	  # POST /users.json
	  def create
	    @user = User.new(user_params)
	
	    respond_to do |format|
	      if @user.save
	        format.html { redirect_to @user, notice: 'User was successfully created.' }
	        format.json { render action: 'show', status: :created, location: @user }
	      else
	        format.html { render action: 'new' }
	        format.json { render json: @user.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # PATCH/PUT /users/1
	  # PATCH/PUT /users/1.json
	  def update
	    respond_to do |format|
	      if @user.update(user_params)
	        format.html { redirect_to @user, notice: 'User was successfully updated.' }
	        format.json { render :show, status: :ok, location: @union }
	      else
	        format.html { render action: 'edit' }
	        format.json { render json: @user.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # DELETE /users/1
	  # DELETE /users/1.json
	  def destroy
	    @user.destroy
	    respond_to do |format|
	      format.html { redirect_to users_url }
	      format.json { head :no_content }
	    end
	  end
	  	
	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_user
		  begin
	        @user = User.by_id(params[:id])
		  rescue Exception => e 	
		    notice = "error #{e} -#{params[:id]}- -#{ZiteActiveRecord.site?}-"
            sql = "select * from users where id = #{params[:id]}"
			res = ActiveRecord::Base.connection.execute(sql)
			res.each do |r|
			  notice += '/n' + r.to_yaml
			end
		    redirect_to users_url, 
			   notice: notice
		  end
	    end
	
	    # Never trust parameters from the scary internet, only allow the white list through.
	    def user_params
	      params.require(:user).permit(:username, :email, :alternate_email, :password, :password_confirmation, :role, :active)
	    end
	    
	end

end

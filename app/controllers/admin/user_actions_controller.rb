module Admin

	class UserActionsController < ApplicationController
	
	  before_action :set_user_action, only: [:show, :edit, :update, :destroy]
	  before_action :only_if_admin
	  
	  # GET /user_actions
	  # GET /user_actions.json
	  def index
	    @user_actions = UserAction.all.order( updated_at: :desc)
	  end
	
	  # GET /user_actions/1
	  # GET /user_actions/1.json
	  def show
	  end
	
	  # GET /user_actions/new
	  def new
	    @user_action = UserAction.new
	  end
	
	  # GET /user_actions/1/edit
	  def edit
	  end
	
	  # POST /user_actions
	  # POST /user_actions.json
	  def create
	    @user_action = UserAction.new(user_action_params)
	
	    respond_to do |format|
	      if @user_action.save
	        format.html { redirect_to @user_action, notice: 'User action was successfully created.' }
	        format.json { render action: 'show', status: :created, location: @user_action }
	      else
	        format.html { render action: 'new' }
	        format.json { render json: @user_action.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # PATCH/PUT /user_actions/1
	  # PATCH/PUT /user_actions/1.json
	  def update
	    respond_to do |format|
	      if @user_action.update(user_action_params)
	        format.html { redirect_to @user_action, notice: 'User action was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html { render action: 'edit' }
	        format.json { render json: @user_action.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # DELETE /user_actions/1
	  # DELETE /user_actions/1.json
	  def destroy
	    @user_action.destroy
	    respond_to do |format|
	      format.html { redirect_to user_actions_url }
	      format.json { head :no_content }
	    end
	  end
	
	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_user_action
	      @user_action = UserAction.where(id: params[:id]).take
	    end
	
	    # Never trust parameters from the scary internet, only allow the white list through.
	    def user_action_params
	      params.require(:user_action).permit(:user_session_id, :controller, :action)
	    end
	   
	end

end
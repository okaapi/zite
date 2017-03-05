module Admin
  
	class UserSessionsController < ApplicationController
	
	  before_action :set_user_session, only: [:show, :edit, :update, :destroy]
	  before_action :only_if_admin
	  
	  # GET /user_sessions
	  # GET /user_sessions.json
	  def index	    
	    if params[:by_name]
          @user_sessions = UserSession.all.order( user_id: :asc )
	    elsif params[:by_ip]
          @user_sessions = UserSession.all.order( ip: :asc )          
	    else
          @user_sessions = UserSession.all.order( updated_at: :desc )
	    end
	  end

	  def stats
	    user_actions = UserAction.all
		actions = {}
        user_actions.each do |u_action|
		  if u_action.action == 'index'
		    if u_action.params =~ /seite: (.*);/
			  h = $1
			else
			  h = u_action.action
			end
	      else
		    h = u_action.action
	      end
		  actions[h] = ( actions[h] ||= 0 ) + 1
		end
		@stats = actions.sort_by { |action, f| -f }
	  end

	  # GET /user_sessions/1
	  # GET /user_sessions/1.json
	  def show
	  end
	
	  # GET /user_sessions/new
	  def new
	    @user_session = UserSession.new
	  end
	
	  # GET /user_sessions/1/edit
	  def edit
	  end
	
	  # POST /user_sessions
	  # POST /user_sessions.json
	  def create
	    @user_session = UserSession.new(user_session_params)
	    respond_to do |format|
	      if @user_session.save
	        format.html { redirect_to @user_session, notice: 'User session was successfully created.' }
	        format.json { render action: 'show', status: :created, location: @user_session }
	      else
	        format.html { render action: 'new' }
	        format.json { render json: @user_session.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # PATCH/PUT /user_sessions/1
	  # PATCH/PUT /user_sessions/1.json
	  def update
	    respond_to do |format|
	      if @user_session.update(user_session_params)
	        format.html { redirect_to @user_session, notice: 'User session was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html { render action: 'edit' }
	        format.json { render json: @user_session.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # DELETE /user_sessions/1
	  # DELETE /user_sessions/1.json
	  def destroy
	    @user_session.destroy
	    respond_to do |format|
	      format.html { redirect_to user_sessions_url }
	      format.json { head :no_content }
	    end
	  end
	
	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_user_session
	      @user_session = UserSession.where(id: params[:id]).take
	    end
	
	    # Never trust parameters from the scary internet, only allow the white list through.
	    def user_session_params
	      params.require(:user_session).permit(:user_id, :client, :ip)
	    end
	
	end
	
end

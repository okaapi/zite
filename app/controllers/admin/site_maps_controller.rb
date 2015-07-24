module Admin
	class SiteMapsController < ApplicationController
	  before_action :set_site_map, only: [:show, :edit, :update, :destroy]
	  before_action :only_if_admin
	
	  # GET /site_maps
	  # GET /site_maps.json
	  def index
	    @site_maps = SiteMap.all
	  end
	
	  # GET /site_maps/1
	  # GET /site_maps/1.json
	  def show
	  end
	
	  # GET /site_maps/new
	  def new
	    @site_map = SiteMap.new
	  end
	
	  # GET /site_maps/1/edit
	  def edit
	  end
	
	  # POST /site_maps
	  # POST /site_maps.json
	  def create
	    @site_map = SiteMap.new(site_map_params)
	
	    respond_to do |format|
	      if @site_map.save
	        format.html { redirect_to @site_map, notice: 'Site map was successfully created.' }
	        format.json { render :show, status: :created, location: @site_map }
	      else
	        format.html { render :new }
	        format.json { render json: @site_map.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # PATCH/PUT /site_maps/1
	  # PATCH/PUT /site_maps/1.json
	  def update
	    respond_to do |format|
	      if @site_map.update(site_map_params)
	        format.html { redirect_to @site_map, notice: 'Site map was successfully updated.' }
	        format.json { render :show, status: :ok, location: @site_map }
	      else
	        format.html { render :edit }
	        format.json { render json: @site_map.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # DELETE /site_maps/1
	  # DELETE /site_maps/1.json
	  def destroy
	    @site_map.destroy
	    respond_to do |format|
	      format.html { redirect_to site_maps_url, notice: 'Site map was successfully destroyed.' }
	      format.json { head :no_content }
	    end
	  end
	
	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_site_map
	      @site_map = SiteMap.find(params[:id])
	    end
	
	    # Never trust parameters from the scary internet, only allow the white list through.
	    def site_map_params
	      params.require(:site_map).permit(:external, :internal, :aux)
	    end
	end
end
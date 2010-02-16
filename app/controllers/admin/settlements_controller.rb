class Admin::SettlementsController < Admin::AdminController
  
  before_filter :load_parent_resources
  
  def index
    @settlements = @municipality.settlements.all
  end
  
  def new
    @settlement = @municipality.settlements.new
  end

  def show
    @settlement = Settlement.find(params[:id])
  end

  def edit
    @settlement = Settlement.find(params[:id])
  end
  
  def create
    @settlement = @municipality.settlements.new(params[:settlement])
    if @settlement.save
      flash[:notice] = t('settlements.create.notice')
      redirect_to admin_county_municipality_settlements_path(@county, @municipality)
    else
      flash.now[:error] = t('settlements.create.error')
      render :action => :new
    end
  end

  def update
    @settlement = Settlement.find(params[:id])
    if @settlement.update_attributes(params[:settlement])
      flash[:notice] = t('settlements.update.notice')
      redirect_to admin_county_municipality_settlements_path(@county, @municipality)
    else
      flash.now[:error] = t('settlements.create.error')
      render :action => :edit
    end
  end
  
  def destroy
    @settlement = Settlement.find(params[:id])
    if @settlement.destroy
      flash[:notice] = t('settlements.destroy.notice')
    else
      flash.now[:error] = t('settlements.destroy.error')
    end
    redirect_to admin_county_municipality_settlements_path(@county, @municipality)
  end
  

  private
  
  def load_parent_resources
    @county = County.find(params[:county_id])
    @municipality = Municipality.find(params[:municipality_id])
  end
end

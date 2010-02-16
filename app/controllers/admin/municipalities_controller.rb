class Admin::MunicipalitiesController < Admin::AdminController
  
  before_filter :load_parent_resources
  
  def index
    @municipalities = @county.municipalities.all
  end
  
  def new
    @municipality = @county.municipalities.new
  end

  def edit
    @municipality = Municipality.find(params[:id])
  end
  
  def create
    @municipality = @county.municipalities.new(params[:municipality])
    if @municipality.save
      flash[:notice] = t('municipalities.create.notice')
      redirect_to admin_county_municipalities_path(@county)
    else
      flash.now[:error] = t('municipalities.create.error')
      render :action => :new
    end
  end

  def update
    @municipality = Municipality.find(params[:id])
    if @municipality.update_attributes(params[:municipality])
      flash[:notice] = t('municipalities.update.notice')
      redirect_to admin_county_municipalities_path(@county)
    else
      flash.now[:error] = t('municipalities.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    @municipality = Municipality.find(params[:id])
    if @municipality.destroy
      flash[:notice] = t('municipalities.destroy.notice')
    else
      flash[:error] = t('municipalities.destroy.error')
    end
    redirect_to admin_county_municipalities_path(@county)
  end

  private
  
  def load_parent_resources
    @county = County.find(params[:county_id])
  end
end

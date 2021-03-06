class Admin::MunicipalitiesController < Admin::AdminController
  filter_resource_access
  # todo: define nested resource
  filter_access_to [:new, :show, :create, :edit, :update], :require => :manage
  
  before_filter :load_parent_resources  
  
  def index
    order = params[:order] ? params[:order] : {'order' => 'ascend_by_name'}
    @search = @county.municipalities.with_permissions_to(:manage, :context => :admin_municipalities).search(params[:search]).search(order)
    @municipalities = @search.paginate(:page => params[:page])
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
      flash[:notice] = t('admin.municipalities.create.notice')
      redirect_to admin_county_municipalities_path(@county)
    else
      flash.now[:error] = t('admin.municipalities.create.error')
      render :action => :new
    end
  end

  def update
    @municipality = Municipality.find(params[:id])
    if @municipality.update_attributes(params[:municipality])
      flash[:notice] = t('admin.municipalities.update.notice')
      redirect_to admin_county_municipalities_path(@county)
    else
      flash.now[:error] = t('admin.municipalities.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    @municipality = Municipality.find(params[:id])
    if @municipality.destroy
      flash[:notice] = t('admin.municipalities.destroy.notice')
    else
      flash[:error] = t('admin.municipalities.destroy.error')
    end
    redirect_to admin_county_municipalities_path(@county)
  end

  private
  
  def load_parent_resources
    @county = County.find(params[:county_id])
  end
end

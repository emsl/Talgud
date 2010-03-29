class Admin::CountiesController < Admin::AdminController
  filter_resource_access
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage
  
  def index
    @search = County.with_permissions_to(:manage, :context => :admin_counties).search(params[:search]).search(params[:order])
    @counties = @search.paginate(:page => params[:page])
  end
  
  def new
    #@county = County.new
  end

  def show
    #@county = County.find(params[:id])
  end

  def edit
    #@county = County.find(params[:id])
  end
  
  def create
    #@county = County.new(params[:county])
    if @county.save
      flash[:notice] = t('admin.counties.create.notice')
      redirect_to admin_counties_path
    else
      flash.now[:error] = t('admin.counties.create.error')
      render :action => :new
    end
  end

  def update
    #@county = County.find(params[:id])
    if @county.update_attributes(params[:county])
      flash[:notice] = t('admin.counties.update.notice')
      redirect_to admin_counties_path
    else
      flash.now[:error] = t('admin.counties.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    #@county = County.find(params[:id])
    if @county.destroy
      flash[:notice] = t('admin.counties.destroy.notice')
    else
      flash[:error] = t('admin.counties.destroy.error')
    end
    redirect_to admin_counties_path
  end  
end

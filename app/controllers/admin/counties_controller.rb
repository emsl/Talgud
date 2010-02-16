class Admin::CountiesController < Admin::AdminController
  
  def index
    @counties = County.all
  end
  
  def new
    @county = County.new
  end

  def show
    @county = County.find(params[:id])
  end

  def edit
    @county = County.find(params[:id])
  end
  
  def create
    @county = County.new(params[:county])
    if @county.save
      flash[:notice] = t('counties.create.notice')
      redirect_to admin_counties_path
    else
      flash.now[:error] = t('counties.create.error')
      render :action => :new
    end
  end

  def update
    @county = County.find(params[:id])
    if @county.update_attributes(params[:county])
      flash[:notice] = t('counties.update.notice')
      redirect_to admin_counties_path
    else
      flash.now[:error] = t('counties.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    @county = County.find(params[:id])
    if @county.destroy
      flash[:notice] = t('counties.destroy.notice')
    else
      flash[:error] = t('counties.destroy.error')
    end
    redirect_to admin_counties_path
  end  
end

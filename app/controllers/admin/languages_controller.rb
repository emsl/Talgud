class Admin::LanguagesController < Admin::AdminController
  filter_resource_access
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage
  
  def index
    order = params[:order] ? params[:order] : {'order' => 'ascend_by_name'}
    @search = Language.with_permissions_to(:manage, :context => :admin_languages).search(params[:search]).search(order)
    @languages = @search.paginate(:page => params[:page])
  end
  
  def new
  end

  def show
  end

  def edit
  end
  
  def create
    if @language.save
      flash[:notice] = t('admin.languages.create.notice')
      redirect_to admin_languages_path
    else
      flash.now[:error] = t('admin.languages.create.error')
      render :action => :new
    end
  end

  def update
    if @language.update_attributes(params[:language])
      flash[:notice] = t('admin.languages.update.notice')
      redirect_to admin_languages_path
    else
      flash.now[:error] = t('admin.languages.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    if @language.destroy
      flash[:notice] = t('admin.languages.destroy.notice')
    else
      flash[:error] = t('admin.languages.destroy.error')
    end
    redirect_to admin_languages_path
  end  
end

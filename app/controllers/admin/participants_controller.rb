class Admin::ParticipantsController < Admin::AdminController

  filter_resource_access :attribute_check => true  
  helper :participations

  def index
    order = params[:order] ? params[:order] : {'order' => 'descend_by_id'}
    @search = EventParticipant.can_manage(@current_user).search(params[:search]).search(order)
    respond_to do |format|
      format.xml {render :xml => @search.all}
      format.csv do
        @participants = @search.all
        @filename = "event-participants-#{Time.now.strftime("%Y%m%d")}.csv"
      end      
      format.xls do
        @participants = @search.all
        @filename = "event-participants-#{Time.now.strftime("%Y%m%d")}.xls"
      end
      format.html {@participants = @search.paginate(:page => params[:page], :include => [:event])}
    end
  end
end
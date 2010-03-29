class Admin::ParticipantsController < Admin::AdminController

  filter_resource_access :attribute_check => true  
  helper :participations

  def index
    p params
    @search = EventParticipant.search(params[:search]).search(params[:order])
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
      format.html {@participants = @search.paginate(:page => params[:page])}
    end
  end
end
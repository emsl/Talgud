class AddressesController < ApplicationController
  
  def municipalities
    render :json => Municipality.all(:select => 'id, name', :conditions => {:county_id => params[:county_id].to_i}, :order => :name).collect{ |m| {:id => m.id, :name => m.name}}
  end
  
  def settlements
    render :json => Settlement.all(:select => 'id, name', :conditions => {:municipality_id => params[:municipality_id].to_i}, :order => :name).collect{ |m| {:id => m.id, :name => m.name}}
  end
end

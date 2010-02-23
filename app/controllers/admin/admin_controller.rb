class Admin::AdminController < ApplicationController

  before_filter :require_user
  filter_resource_access

  layout 'admin'
  
  helper 'admin/admin'
end

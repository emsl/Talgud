class Admin::AdminController < ApplicationController

  before_filter :require_user

  layout 'admin'
  
  helper 'admin/admin'
  
end

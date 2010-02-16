class Admin::AdminController < ApplicationController

  before_filter :require_user
  
end

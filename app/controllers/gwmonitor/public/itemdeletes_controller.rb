class Gwmonitor::Public::ItemdeletesController < ApplicationController

  include System::Controller::Scaffold
  include Gwmonitor::Model::Database
  include Gwmonitor::Controller::Systemname

  def initialize_scaffold
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]
  end

  def index
    check_gw_system_admin
    return authentication_error(403) unless @is_sysadm

    item = Gwmonitor::Itemdelete.new
    item.and :content_id, 0
    @item = item.find(:first)
  end

  def edit
    item = Gwmonitor::Itemdelete.new
    item.and :content_id, 0
    @item = item.find(:first)
    return unless @item.blank?

    @item = Gwmonitor::Itemdelete.create({
      :content_id => 0 ,
      :admin_code => Site.user.code ,
      :limit_date => '1.month'
    })

  end

  def update
    item = Gwmonitor::Itemdelete.new
    item.and :content_id, 0
    @item = item.find(:first)
    return if @item.blank?
    @item.attributes = params[:item]
    location = '/gw/admin_settings'
    _update(@item, :success_redirect_uri=>location)
  end

  def check_gw_system_admin
    @is_sysadm = true if System::Model::Role.get(1, Site.user.id ,'gwmonitor', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,'gwmonitor', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm
  end

end

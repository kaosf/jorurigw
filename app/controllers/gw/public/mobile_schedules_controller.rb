class Gw::Public::MobileSchedulesController < Gw::Admin::SchedulesController
  include Gw::Controller::Mobile::Participant

  def ind_list
    init_params
    @customs = System::CustomGroup.get_my_view
  end

  def list
    init_params
    if params[:group_id].blank? or params[:group_id].to_i == 0
      @group_id = 0
      @items = ""
      @group = ""
    else
      @group_id = params[:group_id].to_i
      @items = System::User.get_user_select(params[:group_id],nil,{:ldap => 1})
      @group = System::Group.find_by_id(params[:group_id])
    end
  end

  def confirm
    init_params

    @line_box = 1
    if !params[:m].blank? && (params[:m] == "new" || params[:m] == "edit")
      item = Gw::Schedule.find(params[:id])
      @items = Gw::Schedule.find(:all, :conditions=>"schedule_parent_id = #{item.schedule_parent_id}")
    else
      @items = Gw::Schedule.find(:all, :conditions=>"id = #{params[:id]}")
    end

    @items.each do |item|
      @auth_level = item.get_edit_delete_level(auth = {:is_gw_admin => @is_gw_admin})
    end

  end

  def delete
    init_params
    @item = Gw::Schedule.find(params[:id])
    auth_level = @item.get_edit_delete_level(auth = {:is_gw_admin => @is_gw_admin})
    return authentication_error(403) if auth_level[:delete_level] != 1

    st = @item.st_at.strftime("%Y%m%d")

      redirect_url = "/gw/schedules/"
      redirect_url += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&uid=#{params[:uid]}&dis=#{params[:dis]}"

    _destroy(@item,:success_redirect_uri=>redirect_url)
  end

  def delete_repeat
    init_params
    item = Gw::Schedule.find(params[:id])
    auth_level = item.get_edit_delete_level(auth = {:is_gw_admin => @is_gw_admin})
    return authentication_error(403) if auth_level[:delete_level] != 1

    st = item.st_at.strftime("%Y%m%d")

    schedule_repeat_id = item.repeat.id

    repeat_items = Gw::Schedule.new.find(:all, :conditions=>"schedule_repeat_id=#{schedule_repeat_id}")
    repeat_items.each { |repeat_item|
        repeat_item.destroy if !repeat_item.is_actual?
    }

      redirect_url = "/gw/schedules/"
      redirect_url += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&uid=#{params[:uid]}&dis=#{params[:dis]}"

    flash_notice '繰り返し一括削除', true
    redirect_to redirect_url
  end

end

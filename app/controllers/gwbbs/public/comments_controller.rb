class Gwbbs::Public::CommentsController < ApplicationController

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @title = Gwbbs::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    initialize_value_set_new_css
  end

  def docs_show

    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :id, params[:p_id]
    item.and "sql", gwbbs_select_status(params)
    @item = item.find(:first)
    Gwbbs::Doc.remove_connection
    return http_error(404) unless @item

    item = gwbbs_db_alias(Gwbbs::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)
    Gwbbs::File.remove_connection
  end

  def edit
    get_role_index
    return http_error(404) unless @is_readable

    item = gwbbs_db_alias(Gwbbs::Comment)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :id, params[:id]
    @comment = item.find(:first)
    Gwbbs::Comment.remove_connection()
    return http_error(404) unless @comment
    params[:p_id] = @comment.parent_id
    docs_show
  end

  def new
    get_role_index
    return http_error(404) unless @is_readable
    docs_show
    item = gwbbs_db_alias(Gwbbs::Comment)
    @comment = item.new({
      :state => 'public' ,
      :published_at => Core.now ,
    })
    Gwbbs::Comment.remove_connection()
 end

  def create
    item = gwbbs_db_alias(Gwbbs::Comment)
    @comment = item.new(params[:comment])
    @comment.title_id = params[:title_id]
    @comment.parent_id = params[:p_id]
    @comment.latest_updated_at = Core.now

    @comment.createdate = Core.now
    @comment.creater_id = Site.user.code unless Site.user.code.blank?
    @comment.creater = Site.user.name unless Site.user.name.blank?
    @comment.createrdivision = Site.user_group.name unless Site.user_group.name.blank?
    @comment.editdate = Core.now
    @comment.editor_id = Site.user.code unless Site.user.code.blank?
    @comment.editor = Site.user.name unless Site.user.name.blank?
    @comment.editordivision = Site.user_group.name unless Site.user_group.name.blank?
    @comment.body = '・' if @comment.body.blank?
    @comment.save

    flash[:notice] = 'コメントを登録しました。'
    redirect_to "/gwbbs/docs/#{params[:p_id]}?title_id=#{params[:title_id]}#{gwbbs_params_set}"
  end

  def update
    item = gwbbs_db_alias(Gwbbs::Comment)
    @comment = item.find(params[:id])
    @comment.attributes = params[:comment]
    @comment.title_id = params[:title_id]
    @comment.parent_id = params[:p_id]
    @comment.latest_updated_at = Core.now
    @comment.editdate = Core.now
    @comment.editor_id = Site.user.code unless Site.user.code.blank?
    @comment.editor = Site.user.name unless Site.user.name.blank?
    @comment.editordivision = Site.user_group.name unless Site.user_group.name.blank?
    @comment.body = '・' if @comment.body.blank?
    @comment.save
    flash[:notice] = 'コメントを更新しました。'
    redirect_to "/gwbbs/docs/#{params[:p_id]}?title_id=#{params[:title_id]}#{gwbbs_params_set}"
  end

  def destroy
    item = gwbbs_db_alias(Gwbbs::Comment)
    @item = item.find(params[:id])
    Gwbbs::Comment.remove_connection()
    _destroy_plus_location(@item, "#{@item.item_path}#{gwbbs_params_set}", :notice => 'コメントを削除しました。')
  end
end

class Gwsub::Public::Sb01::Sb01TrainingGuidesController < ApplicationController
  include System::Controller::Scaffold

  # 受講者向け　利用の手引について、掲示板を案内

  def initialize_scaffold

    return redirect_to(request.env['PATH_INFO']) if params[:reset]

#    error_auth unless params[:content]
#    error_auth unless (@content = Cms::Content.find(params[:content]))
  end

  def index
    init_params
    item = Gwsub::Sb01TrainingGuide.new
#    item.search params
#    item.creator
    #item.categories = params[:cat] unless @cat == '4'
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Sb01TrainingGuide.find(params[:id])
  end

  def user
    init_params
    item = Gwsub::Sb01TrainingGuide.new
#    item.search params
#    item.creator
    item.categories = @cat
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def manager
    init_params
    item = Gwsub::Sb01TrainingGuide.new
#    item.search params
#    item.creator
    item.categories = @cat
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def new
    init_params
    #@l2_current=nz(params[:l2_c],'02')
    @l3_current=nz(params[:l3_c],'02')
    @item = Gwsub::Sb01TrainingGuide.new
    @item.state = '1'
  end
  def create
    init_params
    new_item = Gwsub::Sb01Training.set_f(params[:item])
    @item = Gwsub::Sb01TrainingGuide.new(new_item)
    @cat = @item.categories
    @fyed_id = @item.fyear_id
    location = Gw.chop_with("#{Site.current_node.public_uri}",'/')
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb01TrainingGuide.find(params[:id])
    @cat = @item.categories
    @fyed_id = @item.fyear_id
  end
  def update
    init_params
    @item = Gwsub::Sb01TrainingGuide.find(params[:id])
    new_item = Gwsub::Sb01Training.set_f(params[:item])
    @item.attributes = new_item
    @fyed_id = params[:item]['fyear_id']
    location = "#{Site.current_node.public_uri}#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb01TrainingGuide.find(params[:id])
    location = Gw.chop_with("#{Site.current_node.public_uri}",'/')
    options = {
      :success_redirect_uri=>location}
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb01Training.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin

    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 掲示板分類
    # catgories : 掲示板分類（1:研修一覧・2:受講者向け利用方法・3:企画者向け利用方法）
    @cat = nz(params[:cat],'2')
    @menu_title = "利用の手引"

    @bbs_link_title  = '別ウィンドウ・別タブで案内記事を開きます'

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    #@menu_header3 = 'sb10_proposal_userid_helps'
    case params[:action]
    when 'user'
      @menu_title = "受講者利用の手引"
      @cat          = '1'
      @l1_current=nz(params[:l1_c],'01')
      @l2_current=nz(params[:l2_c],'03')
    when 'manager'
      @menu_title = "企画者利用の手引"
      @cat          = '2'
      @l1_current=nz(params[:l1_c],'02')
      @l2_current=nz(params[:l2_c],'03')
    else
      @menu_title = "ヘルプ設定"
      @cat          = '0'
      @l1_current=nz(params[:l1_c],'03')
      @l2_current=nz(params[:l2_c],'02')
      @l3_current=nz(params[:l2_c],'01')
    end
    #case @cat.to_i
    #when 2
    #  @l1_current=nz(params[:l1_c],'01')
    #  @l2_current=nz(params[:l2_c],'03')
    #when 3
    #  @l1_current=nz(params[:l1_c],'02')
    #  @l2_current=nz(params[:l2_c],'03')
    #when 4
    #  @l1_current=nz(params[:l1_c],'04')
    #  @l2_current=nz(params[:l2_c],'01')
    #  @l3_current=nz(params[:l2_c],'01')
    #else
    #  @l2_current=nil
    #end
  end

  def search_condition
    params[:l1_c]   = nz(params[:l1_c],@l1_current)
    params[:l2_c]   = nz(params[:l2_c],@l2_current)
    params[:cat]    = nz(params[:cat],@cat)
    params[:limit]  = nz(params[:limit], @limits)

    qsa = ['limit' , 's_keyword' , 'cat' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'categories ASC , fyear_markjp DESC , updated_at DESC' )
#    @sort_keys = nz(params[:sort_keys], 'categories ASC , fyear_markjp DESC , bbs_url ASC' )
  end

  def destory
    #試しに
    init_params
    @item = Gwsub::Sb01TrainingGuide.find(params[:id])
  end

end
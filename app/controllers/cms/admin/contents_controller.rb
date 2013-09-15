class Cms::Admin::ContentsController < ApplicationController
  include System::Controller::Scaffold
  
  def initialize_scaffold
  end
  
  def index
    item = Cms::Content.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], :name
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Cms::Content.new.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Cms::Content.new({
      :state      => 'public',
    })
  end
  
  def create
    @item = Cms::Content.new(params[:item])
    _create @item
  end
  
  def update
    @item = Cms::Content.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Cms::Content.new.find(params[:id])
    _destroy @item
  end
  
  def item_to_xml(item, options = {})
    options[:include] = [:status, :publisher]
    xml = ''; xml << item.to_xml(options) do |n|
      n << item.creator.to_xml(:root => 'creator', :skip_instruct => true, :include => [:user, :group]) if item.creator
      n << item.recognizers.to_xml(:root => 'recognizers', :skip_instruct => true, :include => [:user]) if item.recognizers
    end
    return xml
  end
end

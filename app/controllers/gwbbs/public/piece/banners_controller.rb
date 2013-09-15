class Gwbbs::Public::Piece::BannersController < ApplicationController
  include Gwboard::Controller::Authorize
  include Gwbbs::Model::DbnameAlias

  def index
    @title = Gwbbs::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    get_role_new unless params[:piece_param].blank?
  end
end

#####################################################################################
#
#####################################################################################
module Questionnaire::Model::Systemname
  #*****************************************************************************
  #処理毎に記述が変わるので注意
  #画像添付やアップロードの共通処理に値を渡すとき、何の処理かを判別する
  def system_name
    return 'questionnaire'
  end
  def file_base_path
    return "/_attaches/#{self.system_name}"
  end
  #*****************************************************************************
end
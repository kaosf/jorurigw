class Doclibrary::ViewAclFile < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Doclibrary::Model::Systemname
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile

  belongs_to :status, :foreign_key => :state,    :class_name => 'System::Base::Status'
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Doclibrary::Doc'

  def get_keywords_condition(words, *columns)
    cond = Condition.new
    words.to_s.split(/[ 　]+/).each_with_index do |w, i|
      break if i >= 10
      cond.and do |c|
        columns.each do |col|
          qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.or col, 'LIKE', "%#{qw}%"
        end
      end
    end
    return cond
  end

  def item_parent_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    ret = "#{Site.current_node.public_uri}#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}" unless state == 'GROUP'
    ret = "#{Site.current_node.public_uri}#{self.parent_id}/?title_id=#{self.title_id}&gcd=#{self.parent.section_code}" if state == 'GROUP'
    return ret
  end

  def item_doc_path(title,item)
    if title.form_name=='form002'
      return "#{Site.current_node.public_uri}#{item.id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
    else
      return "#{Site.current_node.public_uri}#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
    end
  end

end

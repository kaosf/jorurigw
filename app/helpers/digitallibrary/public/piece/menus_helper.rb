module Digitallibrary::Public::Piece::MenusHelper

  def digitallibrary_folder_trees(items)
    last  = []
    count = []
    if items.size > 0
      class_str = %Q(level#{items[0].level_no})
      if @btmfolder == 1
        html = "<li class='bottom'><ul class='#{class_str}'>\n"
      else
        html = "<li><ul class='#{class_str}'>\n"
      end
      last[items[0].level_no] = 0
      count[items[0].level_no] = 1

      items.each do |item|
        last[items[0].level_no] = 1 if count[items[0].level_no] == items.select{|x| x.state == 'public' }.size
        html << "#{digitallibrary_folder_li(item,last[items[0].level_no])}\n"
        count[items[0].level_no] =  count[items[0].level_no]+1

        check_code = item.id.to_s
        if @folders[item.level_no].to_s == check_code
          str_html = ''
          if params[:f] == 'op'
            unless check_code == params[:cat].to_s
              sub_folders  = item.children.select{|x| x.state == 'public'}
              str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
            end
          else
            sub_folders  = item.children.select{|x| x.state == 'public'}
            str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
          end
          html << str_html unless str_html.blank?
        end if item.children.size > 0 unless params[:fld] == 'fop'

        if params[:fld] == 'fop'
          str_html = ''
          if params[:f] == 'op'
            if @folders[item.level_no] == item.id
              sub_folders  = item.children.select{|x| x.state == 'public'}
              str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
            else
              if item.level_no == 1
                sub_folders  = item.children.select{|x| x.state == 'public'}
                str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
              end
            end
          else
            sub_folders  = item.children.select{|x| x.state == 'public'}
            str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
          end
          html << str_html unless str_html.blank?
        end if item.children.size > 0
      end
    html << "</ul></li>\n"
    end
  end

  def digitallibrary_folder_li(item, last )
    tree_state = false
    @btmfolder = 0
    ret = ''
    tree_state = true unless item.state == 'preparation'
    tree_state = false unless @is_writable
    tree_state = true if item.state == 'public'
    sub_folders  = item.children.select{|x| x.state == 'public'}
    if tree_state
      level_no = 'folder'
      level_no = 'f_plus' unless sub_folders.size == 0
      level_no = 'draft' unless item.state == 'public'
      level_no = 'doc' if item.doc_type == 1 and item.state == 'public'

      if params[:f] == 'op'
        unless params[:fld] == 'fop'
          unless item.id.to_s == params[:cat].to_s
            level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
            level_no = 'open' if params[:fld]=='fop' and item.state=='public' and item.doc_type!= 1
            level_no = 'open current' if item.id.to_s == params[:cat].to_s if item.doc_type == 0
            level_no = 'doc current' if item.id.to_s == params[:cat].to_s if item.doc_type == 1
          else
            level_no = 'folder current'
            level_no = 'f_plus current' unless sub_folders.size == 0
            level_no = 'draft current' unless item.state == 'public'
            level_no = 'doc current' if item.doc_type == 1 and item.state == 'public'
          end
        end

        if params[:fld] == 'fop'
          if @folders[item.level_no].to_s == item.id.to_s
            level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
            level_no = 'open' if params[:fld]=='fop' and item.state=='public' and item.doc_type!= 1
            level_no = 'open current' if item.id.to_s == params[:cat].to_s if item.doc_type == 0
            level_no = 'doc current' if item.id.to_s == params[:cat].to_s if item.doc_type == 1
          end
        end
      else
        level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
        level_no = 'open' if params[:fld]=='fop' and item.state=='public' and item.doc_type!= 1
        level_no = 'open current' if item.id.to_s == params[:cat].to_s if item.doc_type == 0
        level_no = 'doc current' if item.id.to_s == params[:cat].to_s if item.doc_type == 1
      end

      level_no = 'root' if item.level_no == 1
      if level_no == 'open current' || level_no == 'open'
        level_no = level_no + ' noneFolder' if sub_folders.count == 0
      end

       if last.to_i == 1
         if item.doc_type.to_i == 1
          level_no = level_no + " bottomFile"
         else
          level_no = level_no + " bottomFolder"
          if /open/ =~ level_no
            level_no = level_no.gsub(/open /,'')
            level_no = level_no.gsub(/bottomFolder/,' openBottomFolder')
          end
         end
        @btmfolder = 1
      end
      lvnm = ""
      unless item.seq_name.blank?
        lvnm = ""
        lvnm = "[編集]" unless item.state == 'public'
        lvnm = lvnm + "(#{item.seq_name})" if @title.category == 0
      end
      s_fop = ""
      s_fop = "&fld=fop" if params[:fld] == 'fop' if params[:f].blank?

      strparam = ''
      if /open/ =~ level_no
        strparam = "&f=op" unless item.id.to_s == '1'
      end unless sub_folders.count == 0
      strparam = "&f=op" if s_fop == "&fld=fop" if item.doc_type == 1
      ret = "<li class='#{level_no}'>" + link_to(lvnm + item.title.to_s, "#{item.show_path}#{s_fop}#{strparam}")
      ret = "<li class='#{level_no}'><a href='#{item.item_home_path}docs?title_id=#{item.title_id}&cat=#{item.id}#{s_fop}#{strparam}'>#{lvnm}#{h(item.title)}</a>" unless item.doc_type == 1
      ret += "</li>"
    end
    return ret
  end
end

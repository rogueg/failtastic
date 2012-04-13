module ApplicationHelper
  def reply_list(replies)
    return '&mdash;'.html_safe if replies.empty?
    replies.group_by(&:from).map do |from, reps|
      "#{from}" + (reps.count > 1 ? " <span class='dimtext'>(#{reps.count})</span>" : '')
    end.join(', ').html_safe
  end

  def clean_email(txt)
    idx = txt =~ /^On .* wrote:/
    txt = txt[0, idx-1]
    h(txt).gsub(/\=\r?\n/, '')
          .gsub(/\r?\n/, '<br>')
          .gsub(/\=3D/, '=')
          .gsub(/ /, '&nbsp;').html_safe
  end
end

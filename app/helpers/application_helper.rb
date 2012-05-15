module ApplicationHelper
  def date_in_words(date)
    if date.today?
      strftime("%l:%M %p")
    end
  end

  def reply_list(replies)
    return '&mdash;'.html_safe if replies.empty?
    replies.group_by(&:from).map do |from, reps|
      "#{from}" + (reps.count > 1 ? " <span class='dimtext'>(#{reps.count})</span>" : '')
    end.join(', ').html_safe
  end

  def clean_email(txt)
    idx = txt =~ /^On .* wrote:/
    txt = idx ? txt[0, idx-1] : txt # slice out quoted stuff
    txt = h(txt).gsub(/\=\r?\n/, '') # multipart \r\n is nothing
                .gsub(/\r?\n/, '<br>') # real \r\n is actually a newline
                .gsub(/\=3D/, '=') # multipart escaped equal sign
                .gsub(/ /, '&nbsp;') # keep spacing from email

    txt.html_safe
  end

  def recipient_list(recipients)
    res = recipients.any? ? "@ " : ""
    res += recipients.map {|r| "<span class=''>#{r}</span>"}.join(", ")
    res.html_safe
  end

  def render_each(enumerable, partial, var_name='item')
  end

end

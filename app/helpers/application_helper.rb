module ApplicationHelper
  def date_in_words(date)
    d_string = case
      when date.today?; "%l:%M %p"
      when date > 3.days.ago; "%b %e &nbsp;%l:%M %p"
      when date.year == Time.now.year; "%b %e"
    end

    "#{date.strftime(d_string)}&nbsp;&nbsp;<span class='dim'>(#{time_ago_in_words(date)} ago)</span>".html_safe
  end

  def reply_list(replies)
    return '&mdash;'.html_safe if replies.empty?
    replies.group_by(&:from).map do |from, reps|
      "#{from}" + (reps.count > 1 ? " <span class='dimtext'>(#{reps.count})</span>" : '')
    end.join(', ').html_safe
  end

  def clean_email(txt)
    # first strip out multipart crap
    txt = txt.gsub(/\=\r?\n/, '').gsub(/\=3D/, '=')

    # try and remove quoted text
    idx = txt =~ /^On .*\n?.*wrote:/
    idx ||= txt =~ /-+\s*Forwarded/
    txt = idx ? txt[0, idx-1] : txt # slice out quoted stuff

    # turn text spacing into html equivalent
    txt = h(txt).gsub(/\r?\n/, '<br>').gsub(/ /, '&nbsp;')

    txt.html_safe
  end

  def status_sort(fail)
    %w(failing acknowleged pending fixed).map(&:to_sym).index(fail.status)
  end

  def recipient_list(recipients)
    res = recipients.any? ? "@ " : ""
    res += recipients.map {|r| "<span class=''>#{r}</span>"}.join(", ")
    res.html_safe
  end

  def render_each(enumerable, partial, var_name='item')
  end

end

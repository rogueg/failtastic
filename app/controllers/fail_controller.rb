class FailController < ApplicationController
  def raw
    @fals = Fallible.includes :human_replies, :failures
  end

  def current
  end

  def fallible
    @fal = Fallible.find params[:id]
    @curr_fail = @fal.last_failure
    @old_replies = @fal.human_replies.where("sent_at < ?", @curr_fail.started_at)
  end

  def stats
    recent = Failure.recent.to_a

    @by_team = recent.group_by(&:team).map_values do |team, failures|
      Array.wrap(failures).group_by(&:status).map_values(&:length)
    end

    failures = Failure.connection.execute <<-EOF
      select strftime('%s', started_at) as start, strftime('%s', ended_at) as end
      from failures where started_at > datetime('now', '-6 Month')
    EOF
    @fail_by_day = (6.months.ago.beginning_of_day.to_i..Time.now.to_i).step(1.day).inject({}) {|h,i| h[i] = 0; h}
    failures.each{|f|
      @fail_by_day.each{|d,v|
        @fail_by_day[d] = v+1 if f['start'].to_i < d && f['end'].to_i > d
      }
    }
    @fail_by_day = @fail_by_day.map{|d,cnt| {:day => d, :count => cnt}}.sort_by{|v| v[:day]}
  end
end
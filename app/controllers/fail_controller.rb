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
    recent = Failure.recent(1.day).to_a

    @team_max = recent.group_by(&:team).map{|t, failures| failures.length}.max
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

    duration_bins = [1.hour, 3.hours, 12.hours, 1.day, 3.days, 1.week, 2.weeks, 1.month]
    @fail_duration = duration_bins.inject({}) {|h,d| h[d]=0; h }
    @fail_duration[:more_than_month] = 0
    Failure.recent(1.week).to_a.each do |fail|
      dur = fail.duration.to_i
      bin = duration_bins.find {|d| dur < d } || :more_than_month
      @fail_duration[bin] += 1
    end
    @fail_duration = @fail_duration.values
  end
end
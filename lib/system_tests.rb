class SystemTests
  def initialize(env, imap)
    @env = env
    @imap = imap
  end

  def process(msgs)
    # first determine name for each msg
    msgs.each do |msg|
      msg.name = case msg.subject
        when /(product edition|model problems)/; $1
        when /many failures/; 'many failures'
        when /(test_\w+)/; $1
        else raise "unknown: #{msg.subject}"
      end
    end

    # split the msgs into those from humans, and those from bots
    are_humans = msgs.group_by(&:human)

    # humans are easy, we just add a HumanReply
    Array.wrap(are_humans[true]).each {|msg| process_human_reply(msg) }

    # robots are harder, and chatty as hell
    Array.wrap(are_humans[false]).group_by(&:name).each{|k,v| process_robot_group(k,v) }
  end

  def process_human_reply(msg)
    fal = Fallible.where(:kind => 'system_test', :env => @env, :name => msg.name).first_or_create!
    rep = fal.human_replies.where(:from => msg.from.mailbox, :sent_at => msg.date).first_or_create!
    rep.update_attributes! :body => (msg.body.length > 40 ? msg.body : @imap.fetch_body(msg.id)), :to => msg.to.map(&:to_s).join(',')
  end

  # Assume the time range is short, and that all messages are part of the
  # same failure.  This makes the logic much easier because we only care about
  # the first and last message.
  def process_robot_group(name, fail_msgs)
    t_min, t_max = *fail_msgs.map(&:date).minmax
    fal = Fallible.where(:kind => 'system_test', :env => @env, :name => name).first_or_create!

    # update (or create) the failure for this period
    existing = fal.failures.where("ended_at >= ? AND started_at <= ?", t_min-26.hours, t_max).first
    existing ||= fal.failures.create! :started_at => t_min, :ended_at => t_max
    existing.update_attributes! :ended_at => t_max if existing.ended_at < t_max

    # figure out what shard each msg came from.
    fail_msgs.each do |msg|
      msg.shard = msg.body =~ /meraki@([a-z0-9]+)/ ? $1 : 'unknown'
    end

    # for each shard, save the last msg body we got
    fail_msgs.group_by(&:shard).each do |shard, msgs|
      sb = existing.shard_bodies.where(:shard => shard).first_or_create
      sb.update_attributes! :last_failed_at => msgs.last.date, :body => @imap.fetch_body(msgs.last.id)
    end
  end
end
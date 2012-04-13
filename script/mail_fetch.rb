require File.expand_path('../../config/environment',  __FILE__)
require 'net/imap'
require 'ostruct'
require 'pry'

def fetch_between(t0, t1, include_body)
  t0, t1 = *[t0, t1].map{|t| t.strftime("%d-%b-%Y")}
  search_type = include_body ? ["ENVELOPE","BODY.PEEK[1]<0.32>"] : "ENVELOPE"

  print "#{t0} - #{t1}: "
  msgs = @imap.fetch(@imap.search("SINCE #{t0} BEFORE #{t1}"), search_type)
  puts "#{msgs.count} messages"

  msgs.map do |fd|
    envel = fd.attr["ENVELOPE"]
    OpenStruct.new({
      :id => fd.seqno,
      :date => Time.parse(envel.date),
      :subject => envel.subject,
      :from => envel.from.first,
      :body_start => fd.attr["BODY[1]<0>"],
    })
  end
end

def fetch_body(msg_id)
  @imap.fetch([msg_id], "BODY.PEEK[1]")[0].attr["BODY[1]"]
end

def process_system_tests(env, msgs)
  # ignore these for now
  msgs.reject!{|m| m.subject =~ /(product edition|model) problems/}

  # first determine name for each msg
  msgs.each do |msg|
    msg.name = case msg.subject
      when /many failures/; 'many failures'
      when /(test_\w+)/; $1
      else raise "unknown: #{msg.subject}"
    end
  end

  # split the msgs into those from humans, and those from bots
  are_humans = msgs.group_by{|m| !%w(meraki root).include?(m.from.mailbox) }

  # humans are easy, we just add a HumanReply
  Array.wrap(are_humans[true]).each do |msg|
    fal = Fallible.where(:kind => 'system_test', :env => env, :name => msg.name).first_or_create!
    rep = fal.human_replies.where(:from => msg.from.mailbox, :sent_at => msg.date).first_or_create!
    rep.update_attributes :body => fetch_body(msg.id)
  end

  # robots are harder, and chatty as hell
  Array.wrap(are_humans[false]).group_by(&:name).each{|k,v| process_robot_group(env,k,v) }
end

# Assume the time range is short, and that all messages are part of the
# same failure.  This makes the logic much easier because we only care about
# the first and last message.
def process_robot_group(env, name, fail_msgs)
  t_min, t_max = *fail_msgs.map(&:date).minmax
  fal = Fallible.where(:kind => 'system_test', :env => env, :name => name).first_or_create!
  existing = fal.failures.where("ended_at >= ? AND started_at <= ?", t_min-26.hours, t_max).first
  if existing
    existing.update_attributes! :ended_at => t_max if existing.ended_at < t_max
  else
    fal.failures.create! :started_at => t_min, :ended_at => t_max
  end
end

# print "Password: "
# system "stty -echo"
# password = $stdin.gets.chomp
# system "stty echo"

@imap = Net::IMAP.new 'imap.gmail.com', :port => 993, :ssl => {:verify_mode => OpenSSL::SSL::VERIFY_NONE}
@imap.login('some@email.com', 'password')
p @imap.list('', '%').map{|m| m['name']}

@imap.select('PT')
curr = Time.parse('Apr 8')
while curr < Time.parse('Apr 10')
  sts = fetch_between(curr, curr + 1.day, false)
  process_system_tests('production', sts)
  curr += 1.day
end

@imap.logout
@imap.disconnect

require File.expand_path('../../config/environment',  __FILE__)
require 'net/imap'
require 'ostruct'
require 'shiny_opts'
require 'pry'

require 'system_tests'

@opts = ShinyOpts.new do |o|
  o.flag   'fast', 'f'
  o.flag   'poll', 'p'
  o.string 'username', 'u'
  o.string 'start', 's'
end

@cfg = OpenStruct.new YAML.parse_file(File.join(Rails.root, 'config', 'mail.yml')).to_ruby

if @opts.username
  @cfg.username = @opts.username
  print "Password for #{u}: "
  system "stty -echo"
  @cfg.password = $stdin.gets.chomp
  system "stty echo"
end

@imap = Net::IMAP.new @cfg.host, :port => @cfg.port, :ssl => {:verify_mode => OpenSSL::SSL::VERIFY_NONE}
@imap.login(@cfg.username, @cfg.password)
p @imap.list('', '%').map{|m| m['name']}

@imap.select('PT')
@st = SystemTests.new('production', @imap)

if @opts.fast
  @imap.fetch_in_batches Date.parse(@opts.start), Date.today, :width => 15,
    :filter => "NOT FROM meraki@meraki.com NOT FROM root NOT FROM miles",
    :fetch  => ["ENVELOPE", "BODY.PEEK[1]"],
    :handler => lambda {|m| @st.process(m.select(&:human)) }


elsif @opts.poll
  while true
    @last_run ||= Date.today
    msgs = @imap.fetch_range @last_run, Date.tomorrow, :fetch => ["ENVELOPE", "BODY.PEEK[1]<0.32>"]
    @st.process(msgs)
    @last_run = Date.today # last_run lets us avoid skipping records at midnight
    sleep 5.minutes
  end


else
  @imap.fetch_in_batches Date.parse(@opts.start), Date.tomorrow, :width => 1,
    :fetch => ["ENVELOPE", "BODY.PEEK[1]<0.32>"],
    :handler => lambda {|m| @st.process(m)}

end

@imap.logout
@imap.disconnect

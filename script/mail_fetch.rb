require File.expand_path('../../config/environment',  __FILE__)
require 'net/imap'
require 'ostruct'
require 'shiny_opts'

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
  print "Password for #{@opts.username}: "
  system "stty -echo"
  @cfg.password = $stdin.gets.chomp
  system "stty echo"
end

def login(opts={})
  imap = Net::IMAP.new @cfg.host, :port => @cfg.port, :ssl => {:verify_mode => OpenSSL::SSL::VERIFY_NONE}
  imap.login(@cfg.username, @cfg.password)
  imap.select opts[:mailbox] if opts[:mailbox]
  imap
end


if @opts.poll
  while true
    begin
      @last_run ||= Date.today
      imap = login :mailbox => 'PT'
      msgs = imap.fetch_range @last_run, Date.tomorrow, :fetch => ["ENVELOPE", "BODY.PEEK[1]<0.32>"]
      SystemTests.new('production', imap).process(msgs)
      imap.close
      @last_run = Date.today # last_run lets us avoid skipping records at midnight
    rescue => e
      puts ex.message
      puts ex.backtrace.join("\n")
    end
    sleep 5.minutes
  end
end


@imap = login :mailbox => 'PT'
#p @imap.list('', '%').map{|m| m['name']}
@st = SystemTests.new('production', @imap)

if @opts.fast
  @imap.fetch_in_batches Date.parse(@opts.start), Date.today, :width => 15,
    :filter => "NOT FROM meraki@meraki.com NOT FROM root NOT FROM miles",
    :fetch  => ["ENVELOPE", "BODY.PEEK[1]"],
    :handler => lambda {|m| @st.process(m.select(&:human)) }

else
  @imap.fetch_in_batches Date.parse(@opts.start), Date.tomorrow, :width => 1,
    :fetch => ["ENVELOPE", "BODY.PEEK[1]<0.32>"],
    :handler => lambda {|m| @st.process(m)}

end

@imap.close


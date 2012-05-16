RAILS_ROOT = File.expand_path('../',  __FILE__)

God.watch do |w|
  w.name = "mail_fetch"
  w.start = "ruby script/mail_fetch.rb --poll"
  w.keepalive
end

God.watch do |w|
  w.name = "server"
  w.start = "unicorn -p 8099 -E production"
  w.keepalive
end

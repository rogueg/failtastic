require 'net/imap'

Net::IMAP::Address.class_eval do
  def is_human?
    !%w(root meraki).include?(self.mailbox)
  end

  def to_s
    "#{mailbox}@#{host}"
  end
end

Net::IMAP.class_eval do
  def fetch_in_batches(t0, t1, opts, &blk)
    tdiff = opts[:width] || 1
    while t0 < t1
      msgs = fetch_range(t0, t0+tdiff, opts)
      (opts[:handler] || blk).call(msgs)
      t0 += tdiff
    end
  end

  def fetch_range(t0, t1, opts={})
    t0, t1 = *[t0, t1].map{|t| t.strftime("%d-%b-%Y")}
    print "#{t0} - #{t1}: "
    res = search "SINCE #{t0} BEFORE #{t1} #{opts[:filter]}".strip
    msgs = res.any? ? fetch(res, opts[:fetch] || 'ENVELOPE') : []
    puts "#{msgs.count} messages"

    msgs.map do |fd|
      envel = fd.attr["ENVELOPE"]
      OpenStruct.new({
        :id => fd.seqno,
        :date => Time.parse(envel.date),
        :subject => envel.subject,
        :from => envel.from.first,
        :to => Array.wrap(envel.to).compact.select(&:is_human?),
        :human => envel.from.first.is_human?,
        :body => (fd.attr.find{|k,v| k =~ /BODY/} || []).last,
      })
    end
  end

  def fetch_body(msg_id)
    fetch([msg_id], "BODY.PEEK[1]")[0].attr["BODY[1]"]
  end
end
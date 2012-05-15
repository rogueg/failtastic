class HumanReply < ActiveRecord::Base
  belongs_to :fallible

  def to_emails
    emls = self.to.to_s.split(',')
    emls.reject!{|e| e =~ /devel/}

    emls.map{|e| e =~ /^(\w+)@/; $1 }
  end
end

class Fallible < ActiveRecord::Base
  has_many :failures, :dependent => :destroy
  has_many :human_replies, :dependent => :destroy

  def last_failure
    self.failures.order('started_at ASC').last
  end
end

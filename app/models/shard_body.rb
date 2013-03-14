class ShardBody < ActiveRecord::Base
  belongs_to :failure

  def recent?
    self.last_failed_at > 1.day.ago
  end
end
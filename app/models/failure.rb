class Failure < ActiveRecord::Base
  belongs_to :fallible
  has_many :shard_bodies, :dependent => :destroy

  scope :recent, where('ended_at >= ?', 1.day.ago).includes(:fallible)

  def status
    case
    when ended_at < 1.day.ago; 'fixed'
    when replies.where('sent_at > ?', ended_at).first; 'pending'
    when replies.count > 0; 'acknowleged'
    else 'failing'
    end
  end

  def replies
    fallible.human_replies.where('sent_at >= ?', started_at)
  end
end

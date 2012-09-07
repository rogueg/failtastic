class Failure < ActiveRecord::Base
  belongs_to :fallible
  has_many :shard_bodies, :dependent => :destroy

  def self.recent
    Failure.where('ended_at >= ?', 1.day.ago).includes(:fallible)
  end

  def status
    case
    when passing_now?; :fixed
    when replies.where('sent_at > ?', ended_at).first; :pending
    when replies.count > 0; :acknowleged
    else :failing
    end
  end

  def replies
    fallible.human_replies.where('sent_at >= ?', started_at)
  end

  def test_runner
    shard_bodies.last.body =~ /system\/(ts_\w+).rb/ ? $1 : ''
  end

  def passing_now?
    return ended_at < 1.day.ago if test_runner.blank? || test_runner =~ /client_insight|nightly/
    ended_at < 30.minutes.ago
  end

  def team
    case
    when to =~ /backend-errors/; :backend
    else :ui
    end
  end
end

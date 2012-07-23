class FailController < ApplicationController
  def raw
    @fals = Fallible.includes :human_replies, :failures
  end

  def current
  end

  def fallible
    @fal = Fallible.find params[:id]
    @curr_fail = @fal.last_failure
    @old_replies = @fal.human_replies.where("sent_at < ?", @curr_fail.started_at)
  end

end
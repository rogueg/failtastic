class FailController < ApplicationController
  def raw
    @fals = Fallible.includes :human_replies, :failures
  end

  def current
  end

  def fallible
    @fal = Fallible.find params[:id]
    @old_replies = @fal.human_replies.where("sent_at < ?", @fal.last_failure.started_at)
  end

end
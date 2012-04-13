class FailController < ApplicationController
  def raw
    @fals = Fallible.includes :human_replies, :failures
  end

  def current
  end

  def fallible
    @fal = Fallible.find params[:id]
  end

end
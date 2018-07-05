class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def voice
    @request_id = params[:request_id]
    @request = Request.find(@request_id)
  end

  def record
    @request = Request.find(params[:request_id])
    puts params
    
    head :ok
  end
end

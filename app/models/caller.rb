class Caller
  def self.call(request_id)
    request = Request.find(request_id)
    @client = Twilio::REST::Client.new(ENV['account_sid'], ENV['auth_token'])
    call = @client.calls.create(to: "+32498793864", from: "+3278259049", url: "http://c8c992b1.ngrok.io/calls/voice.xml?request_id=#{request_id}", record: true)
  end
end
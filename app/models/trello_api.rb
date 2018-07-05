require "trello"

class TrelloApi
  def initialize
    Trello.configure do |config|
      config.developer_public_key = ENV['trello_key'] # The "key" from step 1
      config.member_token = ENV['trello_token'] # The token from step 2.
    end
  end

  def accept(card)
    card.list_id = "5b3a7a4bdf81e889105993af"
    card.save
  end
  
  def reject(card)
    card.list_id = "5b3a9bf4d268b436bc7b2f00"
    card.save
  end

  def create_request_card(name, description)
    Trello::Card.create(name: name, desc: description, board_id: "96U4Kigb", list_id: "5b3a7a4972ee34864fd37c97")
  end
end
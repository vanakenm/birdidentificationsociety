# README

Live code given at Ruby Belgium in July 2018. Topic was a showcase of the power of API.

Demonstrate:

- Trello: creating & moving cards
- Google Vision: getting info about pictures
- Twilio: Making calls & receiving answers

Steps & stories here below:

## Steps

### Story

I was recently contacted by the bird identification society. Those people help anyone that take a picture of a bird to identify it.

Their normal process is as follow:

- People contact the society via phone
- Clerk tell them to mail the image, their phone number and where they saw the bird
- Clerk receive the info, encode in a [Trello](https://trello.com/b/96U4Kigb/bird-identification-society) board
- Clerk check that it's not a joke (like: it's a bird), reject if not
- Clerk calls an expert, giving him the info
- Expert gives the exact species
- Clerk call the person back and give the info

### Get started

Let's help those people and replace this call with a form

### Create rails app

```bash
rails new birdidentification --database postgresql -T
rake db:migrate
```

Add to Gemfile

```ruby
gem 'google-cloud-vision'nbb
gem 'ruby-trello'
gem 'figaro'
gem 'twilio-ruby'
gem 'byebug'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'sass-rails', '>= 3.2'
```


```scss
# application.scss

@import "bootstrap-sprockets";
@import "bootstrap";
```

Talk about figaro

```bash
bundle
figaro install
cp bis/config/application.yml birdidentification/config
export GOOGLE_APPLICATION_CREDENTIALS=../key.json
rails s
```

### Form

```bash
rails g scaffold Request url where phone
```

* Update generated form & show

### Trello

Now they liked their trello board and don't want another tool

* Show trello API: https://api.trello.com/1/boards/96U4Kigb/lists?fields=name,url&key=xxx
* Show gem: https://github.com/jeremytregunna/ruby-trello
* Create trello_api.rb

```ruby
require 'trello'

class TrelloApi
  def initialize
    Trello.configure do |config|
      config.developer_public_key = ENV['trello_key'] # The "key" from step 1
      config.member_token = ENV['trello_token'] # The token from step 2.
    end
  end

  def create_request_card(name, description)
    Trello::Card.create(name: name, desc: description, board_id: "96U4Kigb", list_id: "5b3a7a4972ee34864fd37c97")
  end
end
```

Let's test this in console then add to controller

```ruby
    trello = TrelloApi.new
    card = trello.create_request_card(@request.where, "#{@request.url}\n#{@request.phone}")
    @request.card_id = card.id
```

We'll need to add a field to our request model to store this card id.

Check if the form generates the card properly

### Avoid the pranksters - is it a bird?

Let's use the Google Vision API to analyse those images

```ruby
class PictureIdentifier
  def self.identify(url)
    require "google/cloud/vision"
    vision = Google::Cloud::Vision.new(project_id: "effin-bot")
    image = vision.image(url)
    image.labels.map(&:description)
  end
end
```

Let's test this before using it in the controller.

```ruby
  contents = PictureIdentifier.identify(@request.url)
  @request.image_contents = contents
```

Again we need a new field for those.


### Avoid the pranksters - accept or reject?

We now can remove all things which does not contains birds:


Let's update a bit our Trello API

```ruby
  def reject(card)
    card.list_id = "5b3a9bf4d268b436bc7b2f00"
    card.save
  end

  def accept(card)
    card.list_id = "5b3a7a4bdf81e889105993af"
    card.save
  end
```

```ruby
 @request.image_contents = contents
    if @request.save
      if contents.include?("bird")
        trello.accept(card)
        redirect_to @request, notice: 'You found a bird!'
      else
        trello.reject(card)
        redirect_to @request, notice: 'No bird here!.'
      end
    else
      redirect_to :new
    end
```

### Getting to our expert

Now, this guy is old fashioned - he only use a phone, never touched this "internet" young people are talking about.

No problem - let's call him with what we found. Enter Twilio.

```ruby
require 'twilio-ruby'

class Caller
  def self.call(request_id)
    request = Request.find(request_id)
    @client = Twilio::REST::Client.new(ENV['account_sid'], ENV['auth_token'])

    call = @client.calls.create(
      to: "+32expert",
        from: "+3278259049",
        url: "http://2fcff55a.ngrok.io/calls/voice.xml?request_id=#{request_id}",
        record: true)
    request.call_id = call.sid
    request.save
  end
end
```

Now, Twilio can't connect to your localhost - it's not on internet. So either we go to prod now... or we use a little nifty software called ngrok.

We need a route to contact us, and then a little XML file.

Let's generate our CallController and make it work

```ruby
class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def voice
    @request_id = params[:request_id]
    @request = Request.find(@request_id)
  end
end
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Hi Stan! A person has found a bird to identify <%= @request.where %>. We think it could be a <%= @request.nice_contents %>. What do you think it is?</Say>
</Response>
```

TwML is an XML language to manage calls... and this is rails, so we can create a xml.erb - as you would create a html.erb.

### Get the expert answer

Twilio can do more than calls - it can record an answer and send it back. Let's do this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Hi Stan! A person has found a bird to identify <%= @request.where %>. We think it could be a <%= @request.nice_contents %>. What do you think it is?</Say>
  <Gather input="speech" action="http://2fcff55a.ngrok.io/calls/record?request_id=<%= @request_id %>">
  </Gather>
</Response>
```

This will send the answer to an action (again we need ngrok or a production server here).

Let's add a bit of work to the controller to get that to work:

```ruby
  def record
    @request = Request.find(params[:request_id])
    @request.expert_answer = params[:SpeechResult]
    @request.save

    head :ok
  end
```

We'll need a field to store the answer, so a small migration should do it.

### Finish the process

Now our clerk only has to put the card in done... and find himself another job!


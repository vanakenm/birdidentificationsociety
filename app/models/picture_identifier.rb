require "google/cloud/vision"

class PictureIdentifier
  def initialize
  end

  def identify(url)
    vision = Google::Cloud::Vision.new(project_id: "effin-bot")
    image = vision.image(url)
    image.labels.map(&:description)
  end
end
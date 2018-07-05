class Request < ApplicationRecord
  def nice_contents
    image_contents.gsub(/[\[\]\"]/, "")
  end
end

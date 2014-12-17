class TinymceAssetsController < ApplicationController
  respond_to :json
  def create
    geometry = Paperclip::Geometry.from_file params[:file]
    image = Image.new params.slice(:file, :alt, :hint)
    image.file_file_name = (Time.now.to_i).to_s + image.file_file_name
    image.save

    render json: {
        image: {
            url: image.file.url,
            height: geometry.height.to_i/10,
            width: geometry.width.to_i/10
        }
    }, layout: false, content_type: "text/html"
  end
end

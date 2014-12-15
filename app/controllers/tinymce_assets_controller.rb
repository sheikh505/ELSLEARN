class TinymceAssetsController < ApplicationController
  respond_to :json
  def create
    geometry = Paperclip::Geometry.from_file params[:file]
    image = Image.create params.slice(:file, :alt, :hint)
    render json: {
        image: {
            url: image.file.url,
            height: geometry.height.to_i/10,
            width: geometry.width.to_i/10
        }
    }, layout: false, content_type: "text/html"
  end
end

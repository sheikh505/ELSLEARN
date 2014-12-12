class TinymceAssetsController < ApplicationController
  respond_to :json

  def create
    puts "adfasdfasdfafdasdfadf"+params.inspect

   # geometry = Paperclip::Geometry.from_file (Paperclip.io_adapters.for(params[:avatar]))
    image = Image.create params[:file]
    render json: {
        image: {
            url: image.avatar.url,
            height: 100,
            width: 100
          # height: geometry.height.to_i,
            #width: geometry.width.to_i
        }
    }, layout: false, content_type: "text/html"
  end
end



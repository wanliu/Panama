require 'ostruct'

class SlideCell < CommonCell

  def show(opts = {})
    url = "http://tympanus.net/Tutorials/CSS3FullscreenSlideshow/images/%s.jpg"
    
    default_samples = (1..4).map {|i| OpenStruct.new(:src => url % i) }

    @slides = opts[:slides] || default_samples

    render
  end

  def edit
    render
  end

end

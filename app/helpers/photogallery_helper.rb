module PhotogalleryHelper
  
  def valid_photogallery_url?(photogallery_url)
    URI.parse(photogallery_url).host =~ /(www\.)?nagi.ee/
  rescue
    false
  end
  
  def photogallery_area_for(photogallery_url)
    u = URI.parse(photogallery_url)
    
    if u.host =~ /(www\.)?nagi.ee/
      render 'shared/photogallery_nagi', :service_url => get_service_url(photogallery_url), :photogallery_url => photogallery_url
    end
  end
  
  def get_service_url(photogallery_url)
    u = URI.parse(photogallery_url)
    
    if u.host =~ /(www\.)?nagi.ee/
      if u.path =~ /^\/photos\/(.*)\/(\w+)\/(\w+)/
        "http://nagi.ee/services/stream/#{$1}/#{$2}/#{$3}"
      elsif u.path =~ /^\/photos\/(\w+)/
        "http://nagi.ee/services/stream/#{$1}"
      elsif u.path =~ /^\/services\/stream/
        photogallery_url
      end
    end
  end
end
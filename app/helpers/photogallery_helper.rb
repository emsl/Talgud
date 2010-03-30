module PhotogalleryHelper
  
  def valid_photogallery_url?(photogallery_url)
    URI.parse(photogallery_url).host =~ /(www\.)?nagi.ee|(www\.)?flickr.com/
  rescue
    false
  end
  
  def photogallery_area_for(photogallery_url)
    u = URI.parse(photogallery_url)
    
    if u.host =~ /(www\.)?nagi.ee/
      render 'shared/photogallery_nagi', :service_url => get_nagi_service_url(photogallery_url), :photogallery_url => photogallery_url
    elsif u.host =~ /(www\.)?flickr.com/
      photoset_id = get_flickr_photoset_id(photogallery_url)
      render 'shared/photogallery_flickr', :photoset_id => photoset_id, :photogallery_url => photogallery_url if photoset_id
    end
  end
  
  def get_nagi_service_url(photogallery_url)
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
  
  def get_flickr_photoset_id(photogallery_url)
    u = URI.parse(photogallery_url)
    if u.host =~ /(www\.)?flickr.com/ and u.path =~ /\/photos\/(\w+)\/sets\/(\w+)/ then $2 else nil end
  end
end
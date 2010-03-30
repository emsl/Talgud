require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhotogalleryHelper do
  
  describe 'get_service_url' do
    it 'should parse photoset service url from nagi.ee photoset url' do
      helper.get_service_url('http://nagi.ee/photos/user_name/sets/216665/').should == 'http://nagi.ee/services/stream/user_name/sets/216665'
    end

    it 'should parse keywords service url from nagi.ee keywords url' do
      helper.get_service_url('http://nagi.ee/photos/user_name/keywords/foobar/').should == 'http://nagi.ee/services/stream/user_name/keywords/foobar'
    end
    
    it 'should not modify the stream url for nagi.ee' do
      helper.get_service_url('http://nagi.ee/services/stream/user_name/sets/216665').should == 'http://nagi.ee/services/stream/user_name/sets/216665'
    end
    
    it 'should parse user account service url from nagi.ee user account url' do
      helper.get_service_url('http://nagi.ee/photos/user_name').should == 'http://nagi.ee/services/stream/user_name'
    end

    it 'should parse urls from www.nagi.ee' do
      helper.get_service_url('http://www.nagi.ee/photos/user_name').should == 'http://nagi.ee/services/stream/user_name'
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper, 'urls_to_links' do
  
  it 'should convert URLs inside plain text to links' do
    helper.urls_to_links('Test http://www.example.com url').should eql('Test <a href="http://www.example.com">http://www.example.com</a> url')
    helper.urls_to_links('Test http://www.example.com/foo.html url', :target => :blank).should eql('Test <a href="http://www.example.com/foo.html" target="blank">http://www.example.com/foo.html</a> url')
  end
end

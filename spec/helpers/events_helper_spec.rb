require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsHelper, 'duration times' do
  
  it 'should return simply formatted output of duration times' do
    event = Factory.build(:event)
    event.begin_time = '12:00'
    event.end_time = '18:00'
    
    helper.duration_times(event).should eql('12-18')
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsHelper do
  describe 'duration times' do
    it 'should return simply formatted output of duration times' do
      event = Factory.build(:event)
      event.begin_time = '12:00'
      event.end_time = '18:00'
      
      helper.duration_times(event).should eql('12-18')
    end
  end
  
  describe 'languages label' do
    it 'should return names of event languages as sentence' do
      language1, language2 = [Factory.build(:language), Factory.build(:language)]
      
      event = Factory.build(:event)
      event.languages = [language1, language2]
      
      helper.languages_label(event).should eql("#{language1.name}, #{language2.name}")
    end
  end
end

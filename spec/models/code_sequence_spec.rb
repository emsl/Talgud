require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CodeSequence do
  before(:each) do
    @valid_attributes = {
      :code => 'Event', :sequence => '102929'
    }
  end

  it "should create a new instance given valid attributes" do
    CodeSequence.create!(@valid_attributes)
  end
  
  it "should create a new sequence in code scope starting at one" do
    cs = Factory(:code_sequence)
    cs.should be_valid
    cs.value.should eql(1)

    cs = Factory(:code_sequence)
    cs.should be_valid
    cs.value.should eql(1)
  end  

  it "should create a new sequence on create starting at one" do
    cs = Factory(:code_sequence)
    cs.should be_valid
    cs.value.should eql(1)

    cs = Factory(:code_sequence, :value => 2)
    cs.should be_valid
    cs.value.should eql(1)
  end  

  it "should create a new sequence in starting at one" do
    cs = CodeSequence.next_value(self, '100302')
    cs.should be_valid
    cs.value.should eql(1)
    cs.label.should eql('1003021')
    
    cs = CodeSequence.next_value(self, '100302')
    cs.value.should eql(2)
    cs.label.should eql('1003022')

    cs = CodeSequence.next_value(self, '100303')
    cs.value.should eql(1)
    cs.label.should eql('1003031')
  end  

  it "should create a new sequence in default date pattern" do
    cs = CodeSequence.next_value(self)
    cs.should be_valid
    cs.value.should eql(1)
    cs.label.should eql("#{Time.now.strftime('%y%m%d')}#{cs.value}")
  end  
end

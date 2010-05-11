require 'spec_helper'

describe CarFactory do
  context "during configuration" do
    it "should be a singleton" do
      CarFactory.should be_respond_to :instance
      expect {CarFactory.new}.to raise_error
    end
  
    it "should have a default probability percentage" do
      CarFactory.instance.probability.should == 0.8
    end
    
    it "should have maximum number of cars that can be created per tick" do
      CarFactory.instance.tries_per_tick.should == 1
    end
  
    it "should have a reference to the building" do
      CarFactory.instance.should be_respond_to(:building)
    end
    
    it "should calculate a successful window based on the probability" do
      CarFactory.instance.probability = 0.1
      CarFactory.instance.successful_window.should == (0..9)
      CarFactory.instance.probability = 0.5
      CarFactory.instance.successful_window.should == (0..49)
      CarFactory.instance.probability = 0.9
      CarFactory.instance.successful_window.should == (0..89)
      CarFactory.instance.probability = 1
      CarFactory.instance.successful_window.should == (0..99)
    end
  end
  
  context "during simulation" do
    before(:each) do
      CarFactory.instance.building = mock("Building", :gates => {:floor => 0, :row => 0})
    end
    
    it "should attempt to bring new cars" do
      CarFactory.attempt_creation
    end
    
    it "should randomized the attempts based on the probability" do
      CarFactory.instance.should_receive(:rand).with(100)
      CarFactory.attempt_creation
    end
    
    it "should create a car if the roll falls in the successful window" do
      CarFactory.instance.probability = 0.1
      CarFactory.instance.stub!(:rand).and_return(0)
      CarFactory.attempt_creation.should_not be_nil
    end
    
    it "should not create a car if the roll falls out of the successful window" do
      CarFactory.instance.probability = 0.1
      CarFactory.instance.stub!(:rand).and_return(10)
      CarFactory.attempt_creation.should be_nil
    end
    
    it "should always create a car if the probability is 100%" do
      CarFactory.instance.probability = 1
      CarFactory.attempt_creation.should_not be_nil
    end
    
    it "should never create a car if the probability is 0%" do
      CarFactory.instance.probability = 0
      CarFactory.attempt_creation.should be_nil
    end
  end
end
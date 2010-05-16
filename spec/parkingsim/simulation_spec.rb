require 'spec_helper'

describe Simulation do
  before(:each) do
    EventQueue.instance.events.clear
    Simulation.cars.clear
    CarFactory.instance.building = mock("building", :gates => [{:floor => 0, :row => 0}])
    CarFactory.stub!(:attempt_creation).and_return nil
  end
  
  def mock_car
    mock("car", :decide_next_action! => :park!, 
                :next_action => :park!, 
                :action_time => 3,
                :randomize_direction => true,
                :on? => true, 
                :park! => true,
                :ticks => 0,
                :ticks= => 0)
  end
  
  context "retrieving messages from event queue" do
    it "should tick even if no events are on the queue" do
      # by default the queue is empty
      Simulation.tick
    end
    
    it "should get the next events from the event queue" do
      EventQueue.should_receive(:next_events!).and_return([])
      Simulation.tick
    end
    
    it "should increase the tick of each car" do
      Simulation.should_receive(:increment_ticks)
      Simulation.tick
    end
  
    it "should send the message to the objects" do
      object = mock("object", :message => "hello!")
      EventQueue.add_event(object, :message)
      object.should_receive(:message).and_return("hello!")
      Simulation.tick
    end
  end
  
  context "dealing with the car factory" do
    it "should call the car factory to attempt to create a car" do
      CarFactory.should_receive(:attempt_creation)
      Simulation.tick
    end
  
    it "should store all the car instances" do
      car = mock_car
      CarFactory.stub!(:attempt_creation).and_return car
      Simulation.tick
      Simulation.cars.length.should == 1
      Simulation.cars.first.should == car
    end
  end
  
  context "getting new events for the queue" do
    before(:each) do
      3.times { Simulation.cars << mock_car } 
    end
    
    it "should only use cars that are not in the event queue" do
      Simulation.available_cars.length.should == 3
      Simulation.available_cars.each do |car| 
        (EventQueue.instance.events.find { |e| e.object == car }).should be_nil
      end
    end
    
    it "should not list a queued car as available" do
      EventQueue.add_event(Simulation.cars[0], :move!)
      Simulation.available_cars.length == 2
    end
    
    it "should decide the next action for the cars" do
      c1 = Simulation.cars[0]
      c2 = Simulation.cars[1]
      c3 = Simulation.cars[2]
      
      c1.should_receive(:decide_next_action!)
      c2.should_receive(:decide_next_action!)
      c3.should_receive(:decide_next_action!)
      
      Simulation.tick
    end
    
    it "should add 3 events to the queue" do
      EventQueue.should_receive(:add_event).exactly(3).times
      Simulation.tick
    end
    
    it "should only deal with cars that are running" do
      parked_car = mock("car", :on? => false)
      Simulation.cars << parked_car
      Simulation.cars.length.should == 4
      EventQueue.should_receive(:add_event).exactly(3).times
      Simulation.tick
    end
    
  end
  
end
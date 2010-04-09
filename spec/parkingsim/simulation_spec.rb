require 'spec_helper'

describe Simulation do
  before(:each) do
    EventQueue.instance.events.clear
    Simulation.cars.clear
    CarFactory.instance.building = mock("building", :gates => [{:floor => 0, :row => 0}])
  end
  
  it "should get the next events from the event queue" do
    EventQueue.should_receive(:next_events!).and_return([])
    Simulation.tick
  end
  
  it "should send the message to the objects" do
    object = mock("object", :message => "hello!")
    EventQueue.add_event(object, :message)
    object.should_receive(:message).and_return("hello!")
    Simulation.tick
  end
  
  it "should tick even if no events are on the queue" do
    # by default the queue is empty
    Simulation.tick
  end
  
  it "should call the car factory to attempt to create a car" do
    CarFactory.should_receive(:attempt_creation)
    Simulation.tick
  end
  
  it "should store all the car instances" do
    car = mock("car")
    CarFactory.stub!(:attempt_creation).and_return car
    Simulation.tick
    Simulation.cars.length.should == 1
    Simulation.cars.first.should == car
  end
  
end
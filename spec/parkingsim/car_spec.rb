require 'spec_helper'

describe Car do
  let(:building) { Building.new :floors => 3, :rows => 10, :spots => 10 }
  let(:car) { Car.new building }
  
  context "getting into the building" do
    it "should log creation" do
      Car.should_receive(:log)
      Car.new building
    end
    
    it "should either be on or off" do
      car.should be_on
      car.should_not be_off
      car.decide_next_action!
      car.park!
      car.should_not be_on
      car.should be_off
    end
    
    it "should be moving forward" do
      car.direction.should == :forward
    end
    
    it "should start at any of the initial locations" do
      car.building.gates << {:floor => 1, :row => 0}
      car.building.gates << {:floor => 2, :row => 0}
      car.stub!(:rand).with(car.building.gates.length).and_return 2
      car.reset!
      car.current_location.should == {:floor => 2, :row => 0}
    end
    
    it "should be on" do
      car.should be_on
    end
  end
  
  context "using driving logic" do
    context "with spots available in the current row" do
      before(:each) do
        car.building.should_receive(:free_spots_on).with(:floor => 0, :row => 0).and_return([0, 1, 2, 3, 4, 5, 6, 7])
      end
            
      it "should suggest the closest spot available" do
        car.look_for_spot.should == {:floor => 0, :row => 0, :spot => 0}
      end
      
      it "should schedule the next move to be a parking attempt" do
        car.decide_next_action!
        car.next_action.should == :park!
        car.drive_intention.should be_nil
        car.park_intention.should == {:floor => 0, :row => 0, :spot => 0}
      end
    end
    
    context "with no spots available in the current row" do
      before(:each) do
        car.building.stub!(:free_spots_on).with(:floor => 0, :row => 0).and_return([])
      end
      
      it "should not find parking" do
        car.look_for_spot.should be_nil
      end
      
      it "should log when it moves to another row" do
        car.decide_next_action!
        Car.should_receive(:log)
        car.move!
      end
      
      it "should schedule a move to the next row" do
        car.decide_next_action!
        car.next_action.should == :move!
        car.park_intention.should be_nil
        car.drive_intention.should == {:floor => 0, :row => 1}
      end
      
      it "should look for rows on the next floor if the current floor is full" do
        # jump to row 7
        car.current_location[:row] = 7
        
        car.decide_next_row!.should == {:floor => 0, :row => 8}
        car.move!
        car.decide_next_row!.should == {:floor => 0, :row => 9}
        car.move!
        car.decide_next_row!.should == {:floor => 1, :row => 0}
      end
      
      it "should turn around once it finds that the parking building is full" do
        # jump to floor 2 row 7
        car.current_location[:floor] = 2
        car.current_location[:row] = 7
        
        car.decide_next_row!.should == {:floor => 2, :row => 8}
        car.move!
        car.decide_next_row!.should == {:floor => 2, :row => 9}
        car.move!
        car.decide_next_row!.should == {:floor => 2, :row => 8}
        car.move!
        car.decide_next_row!.should == {:floor => 2, :row => 7}
      end
      
      it "should turn around again once it reaches the begining of the parking lot" do
        # turn around, jump to floor 0 row 2
        car.invert_direction!
        car.current_location[:floor] = 0
        car.current_location[:row] = 2
        
        
        car.decide_next_row!.should == {:floor => 0, :row => 1}
        car.move!
        car.decide_next_row!.should == {:floor => 0, :row => 0}
        car.move!
        car.decide_next_row!.should == {:floor => 0, :row => 1}
        car.move!
        car.decide_next_row!.should == {:floor => 0, :row => 2}
      end
    end
  end
  
  context "parking" do
    before(:all) do
      car.decide_next_action!
    end
    
    it "should check again if another car parked" do
      car.building.should_receive(:free_spot?).twice.with(car.park_intention).and_return true
      car.park!
    end
    
    it "should be off after parking" do
      car.park!
      car.should be_off
    end
    
    context "when the spot is free" do
      before(:each) do
        car.building.stub!(:free_spot?).with(car.park_intention).and_return true
      end
      
      it "should park the car in the building" do
        car.building.should_receive(:take_spot!).with(car.park_intention)
        car.park!.should == true
      end
      
      it "should log that it parked" do
        Car.should_receive(:log)
        car.park!
      end
    end
    
    context "when the spot is not free" do
      before(:each) do
        car.building.stub!(:free_spot?).with(car.park_intention).and_return false
      end
      
      it "should log that it didn't park" do
        Car.should_receive(:log)
        car.park!
      end
      
      it "should not park if a car was already parked" do
        car.park!.should == false
      end
    
      it "should stay on waiting for a decision to take" do
        car.park!.should == false
        car.should be_on
      end
    end
  end

  context "calculating action times" do
    it "should take 1 second to move between rows" do
      car.stub!(:next_action).and_return(:move!)
      car.stub!(:current_location).and_return(:floor => 0, :row => 0)
      car.stub!(:drive_intention).and_return(:floor => 0, :row => 1)
      car.action_time.should == 1
    end
    
    it "should take 3 seconds to move between floors" do
      car.stub!(:next_action).and_return(:move!)
      car.stub!(:current_location).and_return(:floor => 0, :row => 9)
      car.stub!(:drive_intention).and_return(:floor => 1, :row => 0)
      
      car.action_time.should == 3
    end
    
    it "should take x + 1 seconds to move to spot x" do
      x = rand(10)
      car.stub!(:next_action).and_return(:park!)
      car.stub!(:park_intention).and_return(:floor => 0, :row => 0, :spot => x)
      
      car.action_time.should == x + 1
    end
  end

  context "running in a simulation" do
    context "at any point" do
      it "should tell me its car id in a nice way" do
        car.to_s.should == "Car: #{car.object_id}"
      end
    end
    
    context "with a spot available in the current row" do
      it "should decide next action to be a park!" do
        car.decide_next_action!
        car.next_action.should == :park!
      end
    
      it "should run park! as the next action" do
        car.decide_next_action!
        car.should_receive(:park!)
        car.send(car.next_action)
      end
    end
    
    context "with no spot available in the current row" do
      before(:each) do
        car.building.stub!(:free_spots_on).and_return []
      end
      
      it "should decide next action to be a move!" do
        car.decide_next_action!
        car.next_action.should == :move!
      end
      
      it "should run move! as the next action" do
        car.decide_next_action!
        car.should_receive(:move!)
        car.send(car.next_action)
      end
    end
  end
end
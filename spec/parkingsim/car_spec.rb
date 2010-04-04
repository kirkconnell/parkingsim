require 'spec_helper'

describe Car do
  let(:building) { Building.new :floors => 3, :rows => 10, :spots => 10 }
  let(:car) { Car.new building }
  
  context "just getting into the building" do
    it "should be driving" do
      car.should be_driving
    end
    
    it "should start at any of the initial locations" do
      car.building.gates << {:floor => 1, :row => 0}
      car.building.gates << {:floor => 2, :row => 0}
      car.should_receive(:rand).with(car.building.gates.length).and_return(2)
      car.reset!
      car.driving_by.should == {:floor => 2, :row => 0}
    end
  end
  
  context "looking for a spot" do
    context "with spots available in the current row" do
      before(:each) do
        car.building.should_receive(:free_spots_on).with(:floor => 0, :row => 0).and_return([0, 1, 2, 3, 4, 5, 6, 7, 8, ])
      end
            
      it "should suggest the closest spot available" do
        car.suggest_a_spot.should == {:floor => 0, :row => 0, :spot => 0}
      end
      
      it "should schedule the next move to be a parking attempt" do
        car.decide_next_move
        car.next_move.should == "park!"
        car.spot_intention.should == {:floor => 0, :row => 0, :spot => 0}
      end
    end
    
    context "with no spots available in the current row" do
      before(:each) do
        car.building.should_receive(:free_spots_on).with(:floor => 0, :row => 0).and_return([])
      end
      
      it "should not suggest a spot if the row is full" do
        car.suggest_a_spot.should be_nil
      end
      
      it "should schedule a move to the next row" do
        car.decide_next_move
        car.next_move.should == "move!"
        car.spot_intention.should be_nil
      end
    end
  end
  
end
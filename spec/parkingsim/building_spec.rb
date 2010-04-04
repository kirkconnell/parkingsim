require 'spec_helper'

describe Building do
  let(:building) do 
    Building.new :floors => 3, :rows => 10, :spots => 10
  end

  context "when configuring" do
    it "should accept dimensions" do
      building.to_ar.length.should == 3
      building.to_ar[0].length.should == 10
      building.to_ar[0][0].length.should == 10
    end
    
    it "should tell me its dimensions" do
      building.floors.should == 3
      building.rows.should == 10
      building.spots.should == 10
    end
    
    it "should have a default gate" do
      building.gates.first.should == { :floor => 0, :row =>0 }
    end
    
    it "should let me modify the gates" do
      building.gates.clear
      building.gates << { :floor => 1, :row => 0 }
      building.gates << { :floor => 1, :row => 5 }
      building.gates << { :floor => 1, :row => 9 }
      building.gates[1].should == { :floor => 1, :row => 5 }
    end
  end
  
  context "when driving" do
    it "should tell me what spots are free on a row" do
      building.free_spots_on(:floor => 0, :row => 1).should == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    end
    
    it "should tell me if a spot is free" do
      building.free_spot?(:floor => 1, :row => 0, :spot => 5).should == true
    end
    
    it "should let me park in a free spot" do
      building.park_at! :floor => 1, :row => 0, :spot => 5
      building.free_spot?(:floor => 1, :row => 0, :spot => 5).should == false
    end
    
    it "should unpark parked cars" do
      building.park_at! :floor => 1, :row => 0, :spot => 5
      building.unpark_from! :floor => 1, :row => 0, :spot => 5
      building.free_spot?(:floor => 1, :row => 0, :spot => 5).should == true
    end
  end
  
  context "avoiding crashes" do
    it "should not let two cars park at the same spot" do
      building.park_at! :floor => 1, :row => 0, :spot => 5
      expect {building.park_at! :floor => 1, :row => 0, :spot => 5}.to raise_error
    end
  end
  
  context "following the laws of physics" do
    it "should not let cars leave a parking spot before they're actually parked there" do
      expect {building.unpark_from! :floor => 1, :row => 0, :spot => 5}.to raise_error
    end
  end
  
end
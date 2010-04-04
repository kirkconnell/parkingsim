require 'spec_helper'

describe Building do
  
  context "when configuring" do
    let(:building) { Building.new }
    
    it "should accept dimensions" do
      building.dimensions :floors => 3, :rows => 10, :spots => 10
      building.to_ar.length.should == 3
      building.to_ar[0].length.should == 10
      building.to_ar[0][0].length.should == 10
    end
  end
end
module Roller
  attr_accessor :probability

  def successful_window
    (0..((self.probability * 100) - 1))
  end
  
  def roll
    rand(100)
  end
  
  def win?
    successful_window.include? roll
  end
end

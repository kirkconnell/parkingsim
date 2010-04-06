require 'singleton'
require 'roller'

class CarFactory
  include Singleton
  include Roller
  attr_accessor :building
  
  def initialize
    self.probability = 0.1
  end
  
  def self.attempt_creation
    Car.new(instance.building) if instance.win?
  end
  
end
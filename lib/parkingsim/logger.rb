module Logger
  def display_delegate(&block)
    @@block = block
  end
  
  def log(message)
    @@messages ||= []
    @@messages << message
    
    @@block ||= nil
    @@block.call(message) unless @@block.nil?
  end
end
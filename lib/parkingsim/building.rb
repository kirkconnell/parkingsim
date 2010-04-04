class Building
  def dimensions(options={})
    @array = []
    options[:floors].times do |floor|
      @array << []
      options[:rows].times do |row|
        @array[floor] << []
        options[:spots].times { @array[floor][row] << false }
      end
    end
    @array
  end
  
  def to_ar
    @array
  end
end
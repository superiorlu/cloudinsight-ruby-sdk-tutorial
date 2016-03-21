class TimeFormater
  def self.now
    Time.now.strftime("%Y-%M-%d %H:%M:%S")
  end
end
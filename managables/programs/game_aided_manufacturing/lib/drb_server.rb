require 'drb/drb'

class DrbServer
  URI="druby://localhost:65000"

  def initialize(front_object)
    @front_object = front_object
  end

  def start
    DRb.start_service(URI, @front_object)
  end
end

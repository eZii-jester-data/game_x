require 'drb/drb'

class DrbServer
  URI="druby://localhost:1234"

  def initialize(front_object)
    @front_object = front_object
  end

  def start
    DRb.start_service(URI, @front_object)
  end
end

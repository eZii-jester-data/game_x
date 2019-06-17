require 'drb/drb'

# The URI for the server to connect to
URI="druby://localhost:1234"

class DrbInterface

  def test
    return "hello from drb"
  end

end

# The object that handles requests on the server
FRONT_OBJECT=DrbInterface.new


DRb.start_service(URI, FRONT_OBJECT)
# # Wait for the drb server thread to finish before exiting.
# DRb.thread.join
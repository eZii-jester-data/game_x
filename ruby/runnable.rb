require_relative 'gam'
require_relative 'lib/drb_server.rb'


gam = Gam.new

DrbServer.new(gam).start

gam.start
require "minitest/autorun"

require 'os'
require 'open3'
require 'drb/drb'


DRb.start_service

module SystemTests
  class AbstractSystemTest < Minitest::Test
    SERVER_URI="druby://localhost:1234"

    def drb_interface
      @drb_interface ||= DRbObject.new_with_uri(SERVER_URI)
    end

    def send_keypress_to_gam_window(key)
      if OS.mac?
        `osascript -e 'tell application "System Events" to tell (every process whose unix id is #{@gam_pid})
          set frontmost to true
          
          keystroke "#{key}"
        end tell'`
      end
    end

    def open_gam_window(&block)
      outer_self = self
      Open3.popen3("ruby runnable.rb") do |stdin, stdout, stderr, thread|
        @gam_pid = thread.pid
        sleep 2

        outer_self.instance_exec(stdin, stdout, &block)

        Process.kill('KILL', @gam_pid)
      end
    end
  end
end

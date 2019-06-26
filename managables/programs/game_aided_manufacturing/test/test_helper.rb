require "minitest/autorun"
require_relative '../gam'
require_relative '../functions/selection_cube'
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
      apple_script("keystroke \"#{key}\"")
    end

    def drag_mouse_from_to_in_gam_window(from, to)
      apple_script("set position of window 1 to {0, 0}")

      cliclick_drag_start(*from)
      cliclick_drag_end(*to) 
    end

    def scroll_out_in_gam_window(factor)
      path = File.expand_path(File.join(File.dirname(__FILE__), 'java-robot'))
      Dir.chdir(path) do
        `java MouseWheel`
      end
    end

    def cliclick_drag_start(x,y)
      `cliclick dd:#{x},#{y}`
    end

    def cliclick_drag_end(x,y)
      `cliclick du:#{x},#{y}`
    end

    def apple_script(script)
      if OS.mac?
        `osascript -e 'tell application "System Events" to tell (every process whose unix id is #{@gam_pid})
          set frontmost to true
          
          #{script}
        end tell'`
      end
    end
    
    def open_gam_window(&block)
      outer_self = self
      Open3.popen3("ruby runnable.rb") do |stdin, stdout, stderr, thread|
        Thread.new {
          open('/var/log/gam.stderr', 'a') { |f|
            begin
              while line = stderr.gets
                f << line
              end
            rescue IOError
            end
          }
        }

        @gam_pid = thread.pid
        sleep 2

        outer_self.instance_exec(stdin, stdout, &block)

        Process.kill('KILL', @gam_pid)
      end
    end
  end
end

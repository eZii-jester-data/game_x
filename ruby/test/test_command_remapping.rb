require "minitest/autorun"
require 'os'
require 'open3'

module SystemTests
  class AbstractSystemTest < Minitest::Test
    def send_keypress_to_gam_window(key)
      if OS.mac?
        `osascript -e 'tell application "System Events" to tell (every process whose unix id is #{@gam_pid})
          set frontmost to true
          
          keystroke "#{key}"
        end tell'`
      end
    end
  end

  class CommandRemapping < AbstractSystemTest
    def test_starting_runnable
      Open3.popen3("ruby runnable.rb") do |stdin, stdout, stderr, thread|
        @gam_pid = thread.pid
        sleep 2
        send_keypress_to_gam_window("y")
        
        puts stdout.gets
        puts stdout.gets
        puts stdout.gets

        stdin.puts("1")
        
        puts stdout.gets

        stdin.puts("z")

        send_keypress_to_gam_window("z")

        @output = stdout.gets
        
        Process.kill('KILL', @gam_pid)
      end    
      assert_match "FunctionWrapper", @output
    end
  end
end
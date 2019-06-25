require_relative 'test_helper.rb'
require 'byebug'

module SystemTests
  class TestCommandRemapping < AbstractSystemTest
    def test_command_remapping
      open_gam_window do |console_stdin, console_stdout|
        send_keypress_to_gam_window("y")
      
        puts console_stdout.gets
        puts console_stdout.gets
        puts console_stdout.gets

        console_stdin.puts("1")
        
        puts console_stdout.gets

        console_stdin.puts("z")

        send_keypress_to_gam_window("z")

        puts "test"

        sleep 1

        byebug

        @output = drb_interface.played_commands.last.class.name
      end

      assert_match "SelectionCube", @output
    end
  end
end
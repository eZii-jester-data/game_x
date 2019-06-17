require_relative 'test_helper.rb'

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

        @output = console_stdout.gets
      end

      assert_match "FunctionWrapper", @output
    end
  end
end
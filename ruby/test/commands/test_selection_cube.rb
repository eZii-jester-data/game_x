require_relative '../test_helper.rb'

module SystemTests
    class TestSelectionCube < AbstractSystemTest
      def test_gets_mouse_down_position
        open_gam_window do |console_stdin, console_stdout|
            sleep  2
            puts 'test'
            puts drb_interface.inspect
            @output = drb_interface.test
        end

        assert_match "hello from drb", @output
      end
    end
  end

class BaseCommand
    def initialize(gam_main_instance)
        @active = true
        @gam_main_instance = gam_main_instance
    end

    def active?
        @active
    end

    def finish
    end

    def mouse_down(vector)
    end

    def mouse_up(vector)
    end
end
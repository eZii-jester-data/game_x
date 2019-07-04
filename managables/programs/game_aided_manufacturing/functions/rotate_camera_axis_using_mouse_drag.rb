
class RotateCameraAxisUsingMouseDrag
    def initialize(gam_main_instance)
        @active = true
        @gam_main_instance = gam_main_instance
    end

    def active?
        @active
    end

    def finish
        @active = false
    end

    def mouse_down(vector)
        @mouse_down = true
    end

    def mouse_move(vector)
        unless @last_point.nil?
            difference_vector = @last_point.sub(vector)

            @gam_main_instance.camera.rotation.x += difference_vector.x
            @gam_main_instance.camera.rotation.y += difference_vector.y
        end

        if @mouse_down
            @last_point = vector
        end
    end

    def mouse_up(vector)
        @mouse_down = false
        finish
    end
end

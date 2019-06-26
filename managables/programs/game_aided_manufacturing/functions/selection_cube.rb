require_relative '../shapes/cube'

class SelectionCube
    def initialize(gam_main_instance)
        @active = true
        @gam_main_instance = gam_main_instance
    end

    def active?
        @active
    end

    def finish
        @active = false
        
        @selection_cube = Cube.new(size_vector: (@second_point - @first_point).abs)
        @selection_cube.position = @first_point
        @gam_main_instance.scene.add(@selection_cube.mittsu_object)
    end

    def mouse_down(vector)
        @first_point = vector
    end

    def mouse_up(vector)
        @second_point = vector
        self.finish
    end
end

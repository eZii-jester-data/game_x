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

        difference_vector = @second_point.sub(@first_point)

        z_size = 2 # unsure how to tackle z size for now, so i'll set it to a default 2 until i found a better solution, then it would be `difference_vector.z.abs`
        size_vector = Mittsu::Vector3.new(difference_vector.x.abs, difference_vector.y.abs, z_size)

        
        @selection_cube = Cube.new(size_vector: size_vector)
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

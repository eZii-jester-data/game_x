require '../shapes/cube'

class SelectionCube
    def initialize
        @active = true
    end

    def active?
        @active
    end

    def finish
        @active = false
        
        @selection_cube = Cube.new(size_vector: (@second_point - @first_point).abs)
        @selection_cube.position = @first_point
    end

    def mouse_down(vector)
        @first_point = vector
    end

    def mouse_up(vector)
        @second_point = vector
        self.finish
    end
end

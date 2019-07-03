class Mittsu::BoxGeometry
    def volume
        @parameters[:width] * @parameters[:height] * @parameters[:depth]
    end
end
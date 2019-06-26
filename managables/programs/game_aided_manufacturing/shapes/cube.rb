class Cube
  attr_accessor :color, :mittsu_object

  def initialize(color: 0x0000ff, size_vector:  [1.0, 1.0, 1.0])
    ::Gam::CUBES.push(self)
    self.color = color
    self.create_mittsu_object
  end

  def create_mittsu_object
    @mittsu_object = Mittsu::Mesh.new(
      Mittsu::BoxGeometry.new(*size_vector),
      Mittsu::MeshBasicMaterial.new(color: self.color)
    )
  end

  def method_missing(method_name, *args, &block)
    @mittsu_object.public_send(method_name, *args, &block)
  end
end

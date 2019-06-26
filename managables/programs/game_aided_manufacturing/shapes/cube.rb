class Cube
  attr_accessor :color, :mittsu_object, :size_vector

  def initialize(color: 0x0000ff, size_vector:  Mittsu::Vector3.new(1.0, 1.0, 1.0))
    ::Gam::CUBES.push(self)
    self.color = color
    self.create_mittsu_object
    self.size_vector = size_vector
  end

  def create_mittsu_object
    @mittsu_object = Mittsu::Mesh.new(
      Mittsu::BoxGeometry.new(self.size_vector.x, self.size_vector.y, self.size_vector.z),
      Mittsu::MeshBasicMaterial.new(color: self.color)
    )
  end

  def method_missing(method_name, *args, &block)
    @mittsu_object.public_send(method_name, *args, &block)
  end
end

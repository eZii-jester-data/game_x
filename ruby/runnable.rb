require 'mittsu'
require 'byebug'

screen_width = 800
screen_height = 600
aspect = screen_width.to_f / screen_height.to_f

renderer = Mittsu::OpenGLRenderer.new width: screen_width, height: screen_height, title: 'TOOLX'

scene = Mittsu::Scene.new

camera = Mittsu::PerspectiveCamera.new(75.0, aspect, 0.1, 1000.0)
camera.position.z = 5.0

plane = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(1.0, 10.0, 10.0),
  Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
)

CUBES = []
cube_index = 0

class Cube
  attr_accessor :color, :mittsu_object

  def initialize(color: 0x0000ff)
    CUBES.push(self)
    self.color = color
    self.create_mittsu_object
  end

  def create_mittsu_object
    @mittsu_object = Mittsu::Mesh.new(
      Mittsu::BoxGeometry.new(1.0, 1.0, 1.0),
      Mittsu::MeshBasicMaterial.new(color: self.color)
    )
  end

  def method_missing(method_name, *args, &block)
    @mittsu_object.public_send(method_name, *args, &block)
  end
end

scene.add(plane)

waiting_for_w_console_command = false

console_function = -> {
  unless waiting_for_w_console_command
    waiting_for_w_console_command = true
    puts "Enter ruby code that will be evaluated in the current session:"

    user_input = gets
    puts "Running code u entered #{user_input}"
    eval(user_input)
    waiting_for_w_console_command = false
  end
}

previously_selected_cube_color = nil
renderer.window.on_key_typed do |key|
  case key
  when GLFW_KEY_A
    plane.rotation.x += 0.5
  when GLFW_KEY_B
    plane.rotation.y += 0.5
  when GLFW_KEY_C
    plane.rotation.x -= 0.5
  when GLFW_KEY_D
    plane.rotation.y -= 0.1
  when GLFW_KEY_E
    camera.position.x -= 0.1
  when GLFW_KEY_F
    camera.position.y -= 0.1
  when GLFW_KEY_G
    camera.position.z -= 0.1
  when GLFW_KEY_H
    camera.position.x += 0.1
  when GLFW_KEY_I
    camera.position.y += 0.1
  when GLFW_KEY_J
    camera.position.z += 0.1
  when GLFW_KEY_K
    scene.add(Cube.new(color: 0x42e5f4).mittsu_object)
  when GLFW_KEY_L
    scene.add(Cube.new(color: 0xf44941).mittsu_object)
  when GLFW_KEY_M
    scene.add(Cube.new(color: 0xf441dc).mittsu_object)
  when GLFW_KEY_N
    CUBES[cube_index].position.x += 0.1
  when GLFW_KEY_O
    CUBES[cube_index].position.x -= 0.1
  when GLFW_KEY_P
    CUBES[cube_index].position.y += 0.1
  when GLFW_KEY_R
    CUBES[cube_index].position.y -= 0.1
  when GLFW_KEY_S
    CUBES[cube_index].material.color.set_hex(previously_selected_cube_color) if previously_selected_cube_color != nil
    cube_index += 1
    if cube_index == CUBES.length
      cube_index = 0
    end
    previously_selected_cube_color = CUBES[cube_index].material.color.hex
    CUBES[cube_index].material.color.set_hex(0xf4e842)
  when GLFW_KEY_T
    CUBES[cube_index].material.color.set_hex(previously_selected_cube_color)  if previously_selected_cube_color != nil
    cube_index -= 1
    if cube_index == -1
      cube_index = [CUBES.length - 1, 0].min
    end
    previously_selected_cube_color = CUBES[cube_index].material.color.hex
    CUBES[cube_index].material.color.set_hex(0xf4e842)
  when GLFW_KEY_U
    scene.remove(plane)
  when GLFW_KEY_V
    scene.add(plane)
  end
end


renderer.window.on_resize do |width, height|
  screen_width, screen_height = width, height
  renderer.width = width
  renderer.height = height
  camera.aspect = width.to_f / height.to_f
  camera.update_projection_matrix
end

raycaster = Mittsu::Raycaster.new

objects_being_moved_by_mouse = []
mouse_position = nil
renderer.window.on_mouse_button_pressed do |button, position|
  mouse_position_normalized = Mittsu::Vector2.new
  mouse_position_normalized.x = (((position.x * 2)/screen_width)*2.0-1.0)
  mouse_position_normalized.y = (((position.y * 2)/screen_height)*-2.0+1.0)
  mouse_position = position.multiply_scalar(2)
  raycaster.set_from_camera(mouse_position_normalized, camera)
  objects_being_moved_by_mouse = raycaster
    .intersect_objects(CUBES)
    .map do |intersected_object_and_meta_information|
      intersected_object_and_meta_information[:object]
  end
end

renderer.window.on_mouse_button_released do |button, position|
  mouse_position_click_release = position.multiply_scalar(2)
  translation_vector = (mouse_position_click_release.sub(mouse_position))
  byebug

  # objects_being_moved_by_mouse.each do |object_being_moved_by_mouse|
  #   object_being_moved_by_mouse.position.x += translation_vector.x
  #   object_being_moved_by_mouse.position.y += translation_vector.y
  # end
end

renderer.window.on_scroll do |offset|
  camera.position.z += offset.y
end

renderer.window.run do
  renderer.render(scene, camera)
end
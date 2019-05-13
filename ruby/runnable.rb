require 'mittsu'
# bundle exec ruby runnable.rb
# where's the path 
# in this livestream
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

renderer = Mittsu::OpenGLRenderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'TOOLX'

scene = Mittsu::Scene.new

camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
camera.position.z = 5.0

plane = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(1.0, 10.0, 10.0),
  Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
)

CUBES = []

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

test_player_adding_object = Cube.new

scene.add(plane)

renderer.window.on_mouse_button_pressed do |button, position|
  # puts position.x
  # puts CUBES.first.position.x
  # puts position.y 
  # puts CUBES.first.position.y
end

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

cube_index = 0
command_pallete = -> {
  if renderer.window.key_down?(GLFW_KEY_A)
    plane.rotation.x += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_B)
    plane.rotation.y += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_C)
    plane.rotation.x -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_D)
    plane.rotation.y -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_E)
    camera.rotation.x += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_F)
    camera.rotation.y += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_G)
    camera.rotation.z += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_H)
    camera.position.x += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_I)
    camera.position.y += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_J)
    camera.position.z += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_K)
    scene.add(Cube.new(color: 0x42e5f4).mittsu_object)
  end

  if renderer.window.key_down?(GLFW_KEY_L)
    scene.add(Cube.new(color: 0xf44941).mittsu_object)
  end

  if renderer.window.key_down?(GLFW_KEY_M)
    scene.add(Cube.new(color: 0xf441dc).mittsu_object)
  end

  if renderer.window.key_down?(GLFW_KEY_N)
    CUBES[cube_index].position.x += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_O)
    CUBES[cube_index].position.x -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_P)
    CUBES[cube_index].position.y += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_R)
    CUBES[cube_index].position.y -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_S)
    cube_index += 1
    if cube_index == CUBES.length # 
      cube_index = 0
    end
  end

  if renderer.window.key_down?(GLFW_KEY_T)
    cube_index -= 1

    if cube_index == -1
      cube_index = CUBES.length - 1
    end
  end

  if renderer.window.key_down?(GLFW_KEY_U)
    scene.remove(plane)
  end

  if renderer.window.key_down?(GLFW_KEY_V)
    scene.add(plane)
  end

  if renderer.window.key_down?(GLFW_KEY_W)
    instance_exec(&console_function)
  end

  if renderer.window.key_down?(GLFW_KEY_X)
    p LOCAL_FUNCTIONS
  end

  if renderer.window.key_down?(GLFW_KEY_Y)
    # browse remote functions / list top ten remote functions (by downloads)
  end

  if renderer.window.key_down?(GLFW_KEY_Z)
    # download remote function
  end
}

command_pallete_1 = -> {
  if renderer.window.key_down?(GLFW_KEY_A)
    camera.rotation.x += 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_B)
    camera.rotation.x -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_C)
    camera.rotation.y -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_D)
    camera.rotation.y -= 0.1
  end

  if renderer.window.key_down?(GLFW_KEY_W)
    instance_exec(&console_function)
  end
}


renderer.window.run do
  instance_exec(&command_pallete)

  renderer.render(scene, camera)
end
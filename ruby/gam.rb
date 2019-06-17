require 'mittsu'
require_relative 'cube.rb/base.rb'
require 'pry-remote'
require 'ast'

class FunctionWrapper
  attr_accessor :function_class, :file_path
  def initialize(file_path)
    @file_path = file_path
    @abstract_syntax_tree = RubyVM::AbstractSyntaxTree
      .parse_file(file_path)
  end

  def to_s
    "Function Wrapper"
  end
end

class Gam
  SELECTED_CUBE_COLOR = 0xf4e842
  CUBES = []
  attr_accessor :functions, :key_map

  def initialize
    self.functions = []
    self.key_map = {}
    load_local_functions

    legacy_initialize
  end


  def remap_functions
    print_local_functions

    p "Enter index of unmapped function:" 
    index_of_unmapped_function = gets.to_i
    p "Enter key to map function to:"
    keyboard_key = gets

    keyboard_key.chomp!

    self.key_map[keyboard_key] = self.functions[index_of_unmapped_function]
  end

  def execute_command(command_wrapper)
    p command_wrapper.inspect
  end

  def legacy_initialize
    @cube_index = 0

    @screen_width = 800
    @screen_height = 600
    aspect = @screen_width.to_f / @screen_height.to_f

    @renderer = Mittsu::OpenGLRenderer.new width: @screen_width, height: @screen_height, title: 'TOOLX'

    @scene = Mittsu::Scene.new

    @camera = Mittsu::PerspectiveCamera.new(75.0, aspect, 0.1, 1000.0)
    @camera.position.z = 5.0

    plane = Mittsu::Mesh.new(
      Mittsu::BoxGeometry.new(1.0, 10.0, 10.0),
      Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
    )

    @scene.add(plane)

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
    @renderer.window.on_key_typed do |key|
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
        @camera.position.x -= 0.1
      when GLFW_KEY_F
        @camera.position.y -= 0.1
      when GLFW_KEY_G
        @camera.position.z -= 0.1
      when GLFW_KEY_H
        @camera.position.x += 0.1
      when GLFW_KEY_I
        @camera.position.y += 0.1
      when GLFW_KEY_J
        @camera.position.z += 0.1
      when GLFW_KEY_K
        @scene.add(Cube.new(color: 0x42e5f4).mittsu_object)
      when GLFW_KEY_L
        @scene.add(Cube.new(color: 0xf44941).mittsu_object)
      when GLFW_KEY_M
        @scene.add(Cube.new(color: 0xf441dc).mittsu_object)
      when GLFW_KEY_N
        CUBES[@cube_index].position.x += 0.1
      when GLFW_KEY_O
        CUBES[@cube_index].position.x -= 0.1
      when GLFW_KEY_P
        CUBES[@cube_index].position.y += 0.1
      when GLFW_KEY_R
        CUBES[@cube_index].position.y -= 0.1
      when GLFW_KEY_S
        CUBES[@cube_index].material.color.set_hex(previously_selected_cube_color) if previously_selected_cube_color != nil
        @cube_index += 1
        if @cube_index == CUBES.length
          @cube_index = 0
        end
        previously_selected_cube_color = CUBES[@cube_index].material.color.hex
        CUBES[@cube_index].material.color.set_hex(SELECTED_CUBE_COLOR)
      when GLFW_KEY_T
        CUBES[@cube_index].material.color.set_hex(previously_selected_cube_color)  if previously_selected_cube_color != nil
        @cube_index -= 1
        if @cube_index == -1
          @cube_index = [CUBES.length - 1, 0].min
        end
        previously_selected_cube_color = CUBES[@cube_index].material.color.hex
        CUBES[@cube_index].material.color.set_hex(SELECTED_CUBE_COLOR)
      when GLFW_KEY_U
        @scene.remove(plane)
      when GLFW_KEY_V
        @scene.add(plane)
      when GLFW_KEY_W
        instance_exec(&console_function)
      when GLFW_KEY_X
        print_local_functions
      when GLFW_KEY_Y
        remap_functions
      when GLFW_KEY_Z
        # binding.remote_pry

        self.execute_command(self.key_map['z'])
        # print_remote_functions
      end
    end


    @renderer.window.on_resize do |width, height|
      @screen_width, @screen_height = width, height
      @renderer.width = width
      @renderer.height = height
      @camera.aspect = width.to_f / height.to_f
      @camera.update_projection_matrix
    end

    raycaster = Mittsu::Raycaster.new

    object_being_moved_by_mouse = nil

    previously_selected_cube_color_1 = nil
    @renderer.window.on_mouse_button_pressed do |button, position|
      normalized = normalize_2d_click(position)
      raycaster.set_from_camera(normalized, @camera)
      object_being_moved_by_mouse = raycaster
        .intersect_objects(CUBES)
        .map \
          do |intersected_object_and_meta_information|
            intersected_object_and_meta_information[:object]
          end
        .first

      if object_being_moved_by_mouse
        previously_selected_cube_color_1 = object_being_moved_by_mouse.material.color
        object_being_moved_by_mouse.material.color = SELECTED_CUBE_COLOR
      end
    end


    @renderer.window.on_mouse_move do |position|
      unless object_being_moved_by_mouse.nil?
        normalized = normalize_2d_click(position)
        normalized_3d = Mittsu::Vector3.new(
          normalized.x,
          normalized.y,
          object_being_moved_by_mouse.position.z
        )

        click_to_world = screen_to_world(normalized_3d, @camera)
        object_being_moved_by_mouse.position.x = click_to_world.x
        object_being_moved_by_mouse.position.y = click_to_world.y
      end
    end

    @renderer.window.on_mouse_button_released do |button, position|
      unless object_being_moved_by_mouse.nil?
        object_been_moved_by_mouse = object_being_moved_by_mouse
        object_being_moved_by_mouse = nil
        normalized = normalize_2d_click(position)
        normalized_3d = Mittsu::Vector3.new(
          normalized.x,
          normalized.y,
          object_been_moved_by_mouse.position.z
        )

        click_to_world = screen_to_world(normalized_3d, @camera)
        object_been_moved_by_mouse.position.x = click_to_world.x
        object_been_moved_by_mouse.position.y = click_to_world.y

        object_been_moved_by_mouse.material.color = previously_selected_cube_color_1
      end
    end

    @renderer.window.on_scroll do |offset|
      @camera.position.z += offset.y
    end
  end

  def print_local_functions
    p self.functions
  end

  def load_local_functions
    Dir[File.dirname(__FILE__) + '/functions/*.rb'].each do |file_path|
      self.functions.push(FunctionWrapper.new(file_path))
    end
  end

  def normalize_2d_click(position)
    new_position = Mittsu::Vector2.new
    new_position.x = (((position.x * 2)/@screen_width)*2.0-1.0)
    new_position.y = (((position.y * 2)/@screen_height)*-2.0+1.0)
    return new_position
  end
    
  def screen_to_world(vector, camera)
    vector.unproject(camera).sub(camera.position).normalize()
    distance = -camera.position.z / vector.z
    vector.multiply_scalar(distance).add(camera.position)
  end

  def start
    @renderer.window.run do
      @renderer.render(@scene, @camera)
    end
  end
end
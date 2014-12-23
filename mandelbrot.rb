#!/usr/bin/env ruby
# reworking the first example from the Red Book 8th ed.
# https://github.com/kestess/opengl8thfirstexample

# based on https://github.com/jstenhouse/opengl-aux/commit/32ff1063243efea24761bc1ef8144e559294e2e5

require 'glfw3'
require 'opengl-core'
require 'opengl-aux'
require 'snow-data'

#### functions ####

def error_check!
  error = GL.glGetError()
  raise "GLError: #{error.to_s(16)}" unless error == GL::GL_NO_ERROR
end

def compile_shader(type, path)
  shader = GL::Shader.new(type)
  path = File.expand_path("./#{path}", File.dirname(__FILE__))
  shader.source = File.open(path).read
  shader.compile
  puts "Compiling #{path}", shader.info_log
  shader
end

def create_shader_program(*shaders)
  program = GL::Program.new
  shaders.each { |shader| program.attach_shader(shader) }
  program.link
  puts "Creating shader program", program.info_log
  program
end

def init_window
  Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, 3)
  Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, 1)
  Glfw::Window.window_hint(Glfw::OPENGL_FORWARD_COMPAT, 1)
  Glfw::Window.window_hint(Glfw::RESIZABLE, 1)
  #Glfw::Window.window_hint(Glfw::OPENGL_PROFILE, Glfw::OPENGL_CORE_PROFILE)
  @window = Glfw::Window.new(1000, 1000, "Mandelbrot")
  @window.make_context_current
end

def init_shaders
  # pass through shaders
  vertex_shader = compile_shader(GL::GL_VERTEX_SHADER, "mandelbrot.vert")
  fragment_shader = compile_shader(GL::GL_FRAGMENT_SHADER, "mandelbrot.frag")
  error_check!

  @program = create_shader_program(vertex_shader, fragment_shader)
  @program.use
  error_check!
end

def init_vertices
  vaos = GL::VertexArray.new
  vaos.bind
  error_check!

  vertex2 = Snow::CStruct.new {
    float :x
    float :y
  }
  vertices = vertex2[6]
  vertices[0].x, vertices[0].y = -1.0, -1.0
  vertices[1].x, vertices[1].y = -1.0, 1.0
  vertices[2].x, vertices[2].y = 1.0, 1.0
  vertices[3].x, vertices[3].y = 1.0, 1.0
  vertices[4].x, vertices[4].y = 1.0, -1.0
  vertices[5].x, vertices[5].y = -1.0, -1.0

  buffers = GL::Buffer.new(GL::GL_ARRAY_BUFFER)
  buffers.bind
  GL.glBufferData(GL::GL_ARRAY_BUFFER, vertices.bytesize, vertices.address, GL::GL_STATIC_DRAW)
  error_check!

  GL.glVertexAttribPointer(0, 2, GL::GL_FLOAT, GL::GL_FALSE, 0, 0)
  GL.glEnableVertexAttribArray(0)
  error_check!
end

def update_uniforms
  GL.glUniform1f(@program.uniform_location('scale'), @scale)
  GL.glUniform2f(@program.uniform_location('center'), *@center)
  puts "scale: #@scale center: #@center"
end

#### script ####

# initialization
Glfw.init
init_window
init_vertices
init_shaders
@scale = 3.0
@center = [-1.0, 0.0]
update_uniforms

@window.set_mouse_button_callback do |window, button, action, _|
  if action == Glfw::RELEASE
    pos = window.cursor_pos
    size = window.size
    @center[0] = (pos[0].to_f / size[0] - 0.5) * @scale + @center[0]
    @center[1] = -(pos[1].to_f / size[1] - 0.5) * @scale + @center[1]
    case button
    when Glfw::MOUSE_BUTTON_1
      @scale /= 2.0
    when Glfw::MOUSE_BUTTON_2
      @scale *= 2.0
    end
    update_uniforms
  end
end

# window loop
until @window.should_close?
  Glfw.wait_events
  GL.glClear(GL::GL_COLOR_BUFFER_BIT | GL::GL_DEPTH_BUFFER_BIT)
  GL.glUniform2f(@program.uniform_location('windowsize'), @window.width, @window.height)
  GL.glDrawArrays(GL::GL_TRIANGLES, 0, 6)
  @window.swap_buffers
end

# teardown
@window.destroy
Glfw.terminate

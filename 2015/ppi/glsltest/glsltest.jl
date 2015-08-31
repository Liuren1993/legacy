# Deps #
using GLFW, ModernGL

# Change path #
# change julia's current working directory to Videre working directory #
# you may need to edit this path, I currently don't know how to do it elegantly. #
if OS_NAME == :Windows
    cd(string(homedir(),"\\Documents\\Back2One5\\julia"))
end
if OS_NAME == :Darwin
    cd(string(homedir(),"/Documents/Back2One5/julia"))
end

# Constants #
const WIDTH = convert(GLuint, 800)
const HEIGHT = convert(GLuint, 800)
const VERSION_MAJOR = 4
const VERSION_MINOR = 3

# Types #
#include("Types.jl")
using Types.AbstractOpenGLData
using Types.AbstractOpenGLVectorData
using Types.AbstractOpenGLMatrixData
using Types.AbstractOpenGLVecOrMatData
using Types.VertexData
using Types.UniformData

# Functions #
# modify GLSL version
function glslversion!(source::ASCIIString, major, minor)
    index = search(source, "#version ")
    source = replace(source, source[index.stop+1:index.stop+2], "$major$minor")
    return source
end

# create shader --> load shader source --> compile shader
function shadercompiler(shaderSource::ASCIIString, shaderType::GLenum)
    typestring = Dict([(GL_COMPUTE_SHADER, "compute"),
                     (GL_VERTEX_SHADER,"vertex"),
                     (GL_TESS_CONTROL_SHADER, "tessellation control"),
                     (GL_TESS_EVALUATION_SHADER, "tessellation evaluation"),
                     (GL_GEOMETRY_SHADER, "geometry"),
                     (GL_FRAGMENT_SHADER, "fragment")])
    # create shader & load source
    shader = glCreateShader(shaderType)
    @assert shader != 0 "Error creating $(typestring[shaderType]) shader."
    shaderSource = glslversion!(shaderSource, VERSION_MAJOR, VERSION_MINOR)
    shaderSourceptr = convert(Ptr{GLchar}, pointer(shaderSource))
    glShaderSource(shader, 1, convert(Ptr{Uint8}, pointer([shaderSourceptr])), C_NULL)
    # compile shader
    glCompileShader(shader)
    # compile error handling
    result = GLint[0]
    glGetShaderiv(shader, GL_COMPILE_STATUS, pointer(result))
    if result[1] == GL_FALSE
        println(" $(typestring[shaderType]) shader compile failed.")
        logLen = GLint[0]
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, pointer(logLen))
        if logLen[1] > 0
            log = Array(GLchar, logLen[1])
            logptr = convert(Ptr{GLchar}, pointer(log))
            written = GLsizei[0]
            writtenptr = convert(Ptr{GLsizei}, pointer(written))
            glGetShaderInfoLog(shader, logLen[1], writtenptr, logptr )
            info = convert(ASCIIString, log)
            println("$info")
        end
    end
    return shader::GLuint
end

# create program handler --> attach shader --> link shader
function programer(shaderArray::Array{GLuint,1})
    # create program handler
    programHandle = glCreateProgram()
    @assert programHandle != 0 "Error creating program object."
    # attach shader
    for s in shaderArray
       glAttachShader(programHandle, s)
    end
    # link
    glLinkProgram(programHandle)
    # link error handling
    status = GLint[0]
    glGetProgramiv(programHandle, GL_LINK_STATUS, pointer(status))
    if status[1] == GL_FALSE
        println("Failed to link shader program.")
        logLen = GLint[0]
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, pointer(logLen))
        if logLen[1] > 0
            log = Array(GLchar, logLen[1])
            logptr = convert(Ptr{GLchar}, pointer(log))
            written = GLsizei[0]
            writtenptr = convert(Ptr{GLsizei}, pointer(written))
            glGetProgramInfoLog(programHandle, logLen[1], writtenptr, logptr )
            info = convert(ASCIIString, log)
            println("$info")
        end
    end
    return programHandle::GLuint
end

# pass data to buffer
function data2buffer(gldata::AbstractOpenGLData, bufferTarget::GLenum, bufferUsage::GLenum )
    # generate buffer
    buffer = GLuint[0]
    glGenBuffers(1, pointer(buffer) )
    # bind target
    glBindBuffer(bufferTarget, buffer[1] )
    # pass data to buffer
    glBufferData(bufferTarget, sizeof(gldata.data), gldata.data, bufferUsage)
    # release target
    glBindBuffer(bufferTarget, 0)
    return buffer[1]
end

# connect buffer data to vertex attributes
function buffer2attrib(buffer::Array{GLuint, 1}, attriblocation::Array{GLuint, 1}, gldata::Array{VertexData, 1})
    # generate vertex array object
    vao = GLuint[0]
    glGenVertexArrays(1, convert(Ptr{GLuint}, pointer(vao)) )
    glBindVertexArray(vao[1])
    # connecting
    @assert length(buffer) == length(attriblocation) "the number of buffers and attributes do not match."
    for i = 1:length(buffer)
        glBindBuffer(GL_ARRAY_BUFFER, buffer[i] )
        glEnableVertexAttribArray(attriblocation[i])
        glVertexAttribPointer(attriblocation[i], gldata[i].component, gldata[i].datatype, GL_FALSE,
                              gldata[i].stride, gldata[i].offset)
    end
    return vao[1]
end

# pass data to uniform
function data2uniform(gldata::UniformData, programHandle::GLuint)
    location = glGetUniformLocation(programHandle, gldata.name)
    # select uniform API
    if gldata.tag == "Scalar"
        functionName = string("glUniform", gldata.suffixsize, gldata.suffixtype)
        expression = Expr(:call, symbol(functionName), location)
        for i = 1:size(gldata)[1]
            push!(expression.args, gldata[i])
        end
    elseif gldata.tag == "Vector"
        functionName = string("glUniform", gldata.suffixsize, gldata.suffixtype, "v")
        expression = Expr(:call, symbol(functionName), location, gldata.count, gldata.data)
    else gldata.tag == "Matrix"
        functionName = string("glUniform", "Matrix", gldata.suffixsize, gldata.suffixtype, "v")
        expression = Expr(:call, symbol(functionName), location, gldata.count, GL_FALSE, gldata.data)
    end
    eval(expression)
end


# GLFW's Callbacks #
# key callbacks : press Esc to escape
function key_callback(window::GLFW.Window, key::Cint, scancode::Cint, action::Cint, mods::Cint)
    if (key == GLFW.KEY_ESCAPE && action == GLFW.PRESS)
        GLFW.SetWindowShouldClose(window, GL_TRUE)
    end
end

# Window Initialization #
GLFW.Init()
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, VERSION_MAJOR)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, VERSION_MINOR)
GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
GLFW.WindowHint(GLFW.RESIZABLE, GL_FALSE)
# there two if-statement below just fit my specific case.
if OS_NAME == :Darwin
    GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE)
end
if OS_NAME == :Windows
    GLFW.DefaultWindowHints()
end
# if that doesn't work, try to uncomment the code below and checkout your OpenGL context version
#GLFW.DefaultWindowHints()

# Create Window #
window = GLFW.CreateWindow(WIDTH, HEIGHT, "Videre", GLFW.NullMonitor, GLFW.NullWindow)
# set callbacks
GLFW.SetKeyCallback(window, key_callback)
# create OpenGL context
GLFW.MakeContextCurrent(window)

#-----------------------------------------------Main-----------------------------------------------#
glViewport(0, 0, WIDTH, HEIGHT)

# shader compiling #
source = readall("./glsltest.vert")
vertexShader = shadercompiler(source, GL_VERTEX_SHADER)
source = readall("./glsltest.frag")
fragmentShader = shadercompiler(source, GL_FRAGMENT_SHADER)

# shader linking #
shaderProgram = programer([vertexShader, fragmentShader])

# Data #

radius = 1.0
θ = 1:360
θ = deg2rad(θ)
x = convert(Vector{GLfloat},radius*sin(θ))
y = convert(Vector{GLfloat},radius*cos(θ))

#position = VertexData(reshape([x',y'],720), GL_FLOAT, 2, 0, C_NULL)

position = VertexData(GLfloat[-1,-1, 1,-1, 1,1, -1,-1, 1,1, -1,1], GL_FLOAT, 2, 0, C_NULL)
positionbuffer = data2buffer(position, GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW)
VAO = buffer2attrib([positionbuffer], GLuint[0], VertexData[position])

# texture #
tex = zeros(GLuint,1)
glGenTextures(1, pointer(tex))
glBindTexture(GL_TEXTURE_2D, tex[1])
glTexStorage2D(GL_TEXTURE_2D, 1, GL_R32F, 18, 160)
#glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
#glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
tex_color1 = GLfloat[1:8000]/8000
tex_color2 = [zeros(GLfloat,4000),ones(GLfloat,4000)]
#tex_color3 = abs(sin(randn(8000)))
#data = reshape([tex_color1', tex_color2'], 16000)
#data = reshape([data',data'], 32000)
#data = reshape([data',data'], 64000)
#=
data = GLfloat[1.0 , 0.0, 1.0 , 0.0,
               0.0 , 0.3, 0.0 , 1.0,
               1.0 , 0.6, 1.0 , 0.0,
               0.0 , 1.0, 0.0 , 1.0]   #reshape([tex_color1',tex_color2'],16000)
=#

#=
data = zeros(180,8000)
for i = 1:180
    data[i,:] = GLfloat[i:8000+i-1]/8000
end

data = reshape(data,180*8000)
=#

data = GLfloat[1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               1.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               1.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               1.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               1.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               1.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 1.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 1.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 1.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 1.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 1.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 1.0,   1.0, 1.0, 1.0, 1.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 0.0,   0.0, 1.0, 0.0, 1.0,   0.0, 0.0, 0.0, 0.0,   1.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 1.0,   0.0, 0.0, 0.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 0.0,   0.0, 1.0, 0.0, 1.0,   0.0, 0.0, 0.0, 0.0,   1.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 1.0,   0.0, 0.0, 0.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 0.0,   0.0, 1.0, 0.0, 1.0,   1.0, 1.0, 1.0, 1.0,   1.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 0.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 0.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   0.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0, 1.0, 0.0,   1.0, 0.0,
               0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 1.0,
               0.0, 0.0, 0.0, 0.0,   0.0, 0.0, 0.0, 0.0,   0.0, 0.0, 0.0, 0.0,   0.0, 0.0, 0.0, 0.0,   0.0, 0.0,
               0.0, 0.0, 0.0, 0.0,   0.0, 0.0, 0.0, 0.0,   0.0, 0.0, 0.0, 0.0,   0.0, 0.0, 0.0, 0.0,   0.0, 0.0,  ]

glTexSubImage2D(GL_TEXTURE_2D,
                                0,
                             0, 0,
                          18, 160,
                 GL_RED, GL_FLOAT,
                        data)




  ## Transform Matrix ##
# Translation #
tx = 0                                     # translation in the x axes
ty = 0.5                                     # translation in the y axes
tz = 0        # translation in the z axes
scale = 1.5
translation = GLfloat[ scale 0.0 0.0 tx;
                       0.0 scale 0.0 ty;
                       0.0 0.0 1.0 tz;
                       0.0 0.0 0.0 1.0 ]

# Rotation Matrix #
θ = 0         # rotation around the x axis by an angle of θ
ϕ =  0      # rotation around the y axis by an angle of ϕ
ψ = pi/7     # rotation around the z axis by an angle of ψ
rotationX = GLfloat[ 1.0     0.0     0.0 0.0;
                     0.0  cos(θ) -sin(θ) 0.0;
                     0.0  sin(θ)  cos(θ) 0.0;
                     0.0     0.0     0.0 1.0 ]

rotationY = GLfloat[  cos(ϕ)  0.0  sin(ϕ) 0.0;
                         0.0  1.0     0.0 0.0;
                     -sin(ϕ)  0.0  cos(ϕ) 0.0;
                         0.0  0.0     0.0 1.0 ]

rotationZ = GLfloat[ cos(ψ) -sin(ψ) 0.0 0.0;
                     sin(ψ)  cos(ψ) 0.0 0.0;
                        0.0     0.0 1.0 0.0;
                        0.0     0.0 0.0 1.0 ]

rotation = rotationZ * rotationY * rotationX


#=
tex = zeros(GLuint,360)
glGenTextures(360, pointer(tex))
for i =1:360
    glBindTexture(GL_TEXTURE_2D, tex[i])
    glTexStorage2D(GL_TEXTURE_2D, 1, GL_R32F, 1, 8000)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
end
=#
#=
vertdata = zeros(GLfloat, 6)
positionbuffer = zeros(GLuint, 360)
VAO = zeros(GLuint, 360)
for i = 1:360
    vertdata = GLfloat[ x[i], y[i], x[i+1], y[i+1], 0.0, 0.0]
    position = VertexData(vertdata, GL_FLOAT, 2, 0, C_NULL)
    positionbuffer[i] = data2buffer(position, GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW)
    VAO[i] = buffer2attrib([positionbuffer[i],texcoordbuffer], GLuint[0,1], VertexData[position,texcoord])
end


tex_color = zeros(GLfloat,8000,360)
glTexSubImage2D(GL_TEXTURE_2D,
                                0,
                             0, 0,
                          1, 8000,
                 GL_RED, GL_FLOAT,
                        tex_color[:,j])

j = 1

Δlight = 1/360

αlevel = zeros(360,360)


αlevel[:, 1] = [1:360]/360
for i = 2:360
    αlevel[:, i] = [αlevel[end, i-1],αlevel[1:end-1, i-1]]
end
αlevel
=#
δ = convert(GLfloat,0)
# loop #
while !GLFW.WindowShouldClose(window)
  #  starttime = time()
    # check and call events
    GLFW.PollEvents()
    # rendering commands here
    glClearColor(0, 0, 0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
    # draw
    glUseProgram(shaderProgram)


    modelViewMatrix = translation * rotation
    modelViewLocation = glGetUniformLocation(shaderProgram, "modelViewMatrix")
    glUniformMatrix4fv(modelViewLocation, 1, GL_FALSE, modelViewMatrix)

    lightLocation = glGetUniformLocation(shaderProgram, "light")
    glUniform1f(lightLocation, δ)

    if δ >= 1.0
        δ = 0
    else
        δ += 0.00005
    end
   # println(δ)


  #=
    glBindTexture(GL_TEXTURE_2D, tex[j])
    glTexSubImage2D(GL_TEXTURE_2D,
                                0,
                             0, 0,
                          1, 8000,
                 GL_RED, GL_FLOAT,
                        tex_color[:,j])
    for i = 1:360
        glBindTexture(GL_TEXTURE_2D, tex[i])
        glBindVertexArray(VAO[i])
        glUniform4f(lightLocation, αlevel[i,j], 0.0, 0.0, 1.0)
        glDrawArrays(GL_TRIANGLES, 0, 3)

    end

    j = j+1
    if j == 361
        j = 1
    end
    =#
    glDrawArrays(GL_TRIANGLES, 0, 6)
    # swap the buffers
    GLFW.SwapBuffers(window)
   # endtime = time()
  #  println(1/(endtime - starttime))
end

# clean up #
glDeleteShader(vertexShader)
glDeleteShader(fragmentShader)
glDeleteProgram(shaderProgram)
#glDeleteTextures(1, tex)
#glDeleteVertexArrays(1, VAO)

# GLFW Terminating #
GLFW.Terminate()

const std = @import("std");
const c = @cImport({
    @cInclude("stb/stb_image.h");
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});
const shader = @import("shader.zig");
pub fn main() !void {


    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window_optional = c.glfwCreateWindow(800,600,"LearnOpenGL", null, null);
    if (window_optional == null) {
        std.debug.print("Failed to Create GLFW window\n", .{});
        c.glfwTerminate();
        return;
    }
    const window = window_optional.?;
    c.glfwMakeContextCurrent(window);

    const loader: c.GLADloadproc = @ptrCast(&c.glfwGetProcAddress);
    if (c.gladLoadGLLoader(loader) == 0) {
        std.log.err("Failed to init glad", .{});
        return;
    }

    c.glViewport(0,0,800,600);
    _ = c.glfwSetFramebufferSizeCallback(window,framebuffer_size_callback);


    const shader_program = try shader.shader_struct.init("src/vertex_shader.glsl","src/fragment_shader.glsl");

    
    const verts = [_]f32{
        // vertices         //colors        // texture coords
        0.5,0.5,0.0,        1.0,0.0,0.0,    1.0,1.0,    // top right
        0.5,-0.5,0.0,       0.0,1.0,0.0,    1.0,0.0,    // bottom right
        -0.5,-0.5,0.0,      0.0,0.0,1.0,    0.0,0.0,    // top left
        -0.5,0.5,0.0,       1.0,1.0,0.0,    0.0,1.0     // bottom left
    };

    const indices = [_]u32{
        0,1,3,
        1,2,3,
    };



    var vbo: c_uint = 0;
    var vao: c_uint = 0;
    var ebo: c_uint = 0;

    const verts_ptr : ?*anyopaque = @constCast(&verts);
    const indices_ptr: ?*anyopaque = @constCast(&indices);

    c.glGenVertexArrays(1,&vao);
    c.glGenBuffers(1,&vbo);
    c.glGenBuffers(1,&ebo);


    c.glBindVertexArray(vao);

    c.glBindBuffer(c.GL_ARRAY_BUFFER,vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(verts)),verts_ptr,c.GL_STATIC_DRAW);

    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER,ebo);
    c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), indices_ptr, c.GL_STATIC_DRAW);

    
    
    c.glVertexAttribPointer(0,3,c.GL_FLOAT, c.GL_FALSE, 8*@sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    const stride = 3 * @sizeOf(f32);
    const offset: ?*anyopaque = @ptrFromInt(stride); 
    c.glVertexAttribPointer(1,3,c.GL_FLOAT,c.GL_FALSE,8*@sizeOf(f32),offset);
    c.glEnableVertexAttribArray(1);

    const texture_stride = 6  * @sizeOf(f32);
    const texture_offset: ?*anyopaque = @ptrFromInt(texture_stride);

    c.glVertexAttribPointer(2,2,c.GL_FLOAT,c.GL_FALSE,8*@sizeOf(f32), texture_offset);
    c.glEnableVertexAttribArray(2);

    var texture: c_uint = 0;
    c.glGenTextures(1, &texture);
    c.glBindTexture(c.GL_TEXTURE_2D, texture);

    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_WRAP_S,c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_WRAP_T,c.GL_REPEAT);

    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_MIN_FILTER,c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_MAG_FILTER,c.GL_LINEAR);

    var width:c_int  = 0;
    var height:c_int = 0;
    var nrChannels:c_int = 0;
    const texture_file = "textures/container.jpg"; 
    const c_texture_file: [*c]const u8 = texture_file ++ "\x00";
    
    c.stbi_set_flip_vertically_on_load(1);
    const data = c.stbi_load(c_texture_file,&width,&height, &nrChannels, 0);
    if (data != null) {
        const texture_ptr: ?*anyopaque = @ptrCast(data); 
        c.glTexImage2D(c.GL_TEXTURE_2D,0,c.GL_RGB, width, height, 0, c.GL_RGB, c.GL_UNSIGNED_BYTE, texture_ptr);
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
        c.stbi_image_free(texture_ptr);

    }
    else {
        std.log.err("Failed to load texture", .{});
    }

    var texture2: c_uint = 0;
    width = 0;
    height = 0;
    nrChannels = 0;
    c.glGenTextures(1, &texture2);
    c.glBindTexture(c.GL_TEXTURE_2D, texture2);

    
    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_WRAP_S,c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_WRAP_T,c.GL_REPEAT);

    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_MIN_FILTER,c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D,c.GL_TEXTURE_MAG_FILTER,c.GL_NEAREST);

    const texture2_file = "textures/awesomeface.png";
    const c_texture2_file: [*c]const u8 = texture2_file ++ "\x00";
    const data2 = c.stbi_load(c_texture2_file, &width,&height,&nrChannels,0);
    if (data2 != null) {
        const texture2_ptr: ?*anyopaque = @ptrCast(data2);
        c.glTexImage2D(c.GL_TEXTURE_2D,0,c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, texture2_ptr);
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
        c.stbi_image_free(texture2_ptr);
    }
    else {
        std.log.err("Failed to load texture", .{});
    }

    // c.glBindBuffer(c.GL_ARRAY_BUFFER,0);
    //
    // c.glBindVertexArray(0);

    // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

    try shader_program.use();
    shader_program.set_int("texture1",0);
    shader_program.set_int("texture2",1);
    while(c.glfwWindowShouldClose(window) == 0) {
        process_input(window,shader_program.id);
        



        c.glClearColor(0.2,0.3,0.3,1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glActiveTexture(c.GL_TEXTURE0);
        c.glBindTexture(c.GL_TEXTURE_2D,texture);
        c.glActiveTexture(c.GL_TEXTURE1);
        c.glBindTexture(c.GL_TEXTURE_2D,texture2);

        try shader_program.use();
        c.glBindVertexArray(vao);

        c.glDrawElements(c.GL_TRIANGLES,6,c.GL_UNSIGNED_INT,null);
        

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glDeleteVertexArrays(1,&vao);
    c.glDeleteBuffers(1,&vbo);
    c.glDeleteProgram(shader_program.id);

    c.glfwTerminate();
    return;

}

pub fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    _ = window; 
    c.glViewport(0,0,width,height);
}

var input: f32 = 0.0;
pub fn process_input(window : *c.GLFWwindow, shader_program_id: c_uint) callconv(.c) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_Q) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }
    else if(c.glfwGetKey(window,c.GLFW_KEY_UP) == c.GLFW_PRESS) {
        input += 0.01;
        c.glUniform1f(c.glGetUniformLocation(shader_program_id,"mix_value"),input);
    }
    else if(c.glfwGetKey(window,c.GLFW_KEY_DOWN) == c.GLFW_PRESS) {
        input -= 0.01;
        c.glUniform1f(c.glGetUniformLocation(shader_program_id,"mix_value"),input);
    }
}



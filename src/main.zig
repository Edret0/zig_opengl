const std = @import("std");
const c = @cImport({
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
        // vertices         //colors
        0.5,-0.5,0.0,       1.0,0.25,0.9,    
        -0.5,-0.5,0.0,      0.3,1.0,0.2,
        0.0,0.5,0.0,        0.5,0.5,1.0,
    };


    var vbo: c_uint = 0;
    var vao: c_uint = 0;
    
    const verts_ptr : ?*anyopaque = @constCast(&verts);

    c.glGenVertexArrays(1,&vao);
    c.glGenBuffers(1,&vbo);

    c.glBindVertexArray(vao);
    c.glBindBuffer(c.GL_ARRAY_BUFFER,vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(verts)),verts_ptr,c.GL_STATIC_DRAW);


    c.glVertexAttribPointer(0,3,c.GL_FLOAT, c.GL_FALSE, 6*@sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    const stride = 3 * @sizeOf(f32);
    const offset: ?*anyopaque = @ptrFromInt(stride); 
    c.glVertexAttribPointer(1,3,c.GL_FLOAT,c.GL_FALSE,6*@sizeOf(f32),offset);
    c.glEnableVertexAttribArray(1);

    c.glBindBuffer(c.GL_ARRAY_BUFFER,0);

    c.glBindVertexArray(0);

    // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

    while(c.glfwWindowShouldClose(window) == 0) {
        process_input(window);
        



        c.glClearColor(0.2,0.3,0.3,1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        try shader_program.use();
        c.glBindVertexArray(vao);

        c.glDrawArrays(c.GL_TRIANGLES,0,3);
        

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

pub fn process_input(window : *c.GLFWwindow) callconv(.c) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_Q) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }
}



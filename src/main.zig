const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});
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
    
    while(c.glfwWindowShouldClose(window) == 0) {
        process_input(window);

        c.glClearColor(0.2,0.3,0.3,1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
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

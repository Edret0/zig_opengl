const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});


pub const shader_struct = struct {
    id: c_uint,
    pub fn init(vertex_path: [] const u8, fragment_path: [] const u8) !shader_struct {
        const alloc = std.heap.page_allocator;
        const vert_file = try std.fs.cwd().openFile(vertex_path,.{});
        defer vert_file.close();

        const vert_stat = try vert_file.stat();
        const vert_file_size = vert_stat.size;

        var vert_file_buf = try alloc.alloc(u8, vert_file_size + 1);

        _ = try vert_file.readAll(vert_file_buf);
        vert_file_buf[vert_file_size] = 0;

        defer alloc.free(vert_file_buf);

        const frag_file = try std.fs.cwd().openFile(fragment_path, .{});
        defer frag_file.close();

        const frag_stat = try frag_file.stat();
        const frag_file_size = frag_stat.size;

        var frag_file_buf = try alloc.alloc(u8,frag_file_size + 1);

        _ = try frag_file.readAll(frag_file_buf);
        frag_file_buf[frag_file_size] = 0;

        defer alloc.free(frag_file_buf);

        const vertex_shader = c.glCreateShader(c.GL_VERTEX_SHADER);
        c.glShaderSource(vertex_shader,1,&(&vert_file_buf[0]),null);
        c.glCompileShader(vertex_shader);

        var success: c_int = 0;
        var infoLog : [512]u8 = undefined;

        c.glGetShaderiv(vertex_shader, c.GL_COMPILE_STATUS, &success);
        
        if (success == 0) {
            c.glGetShaderInfoLog(vertex_shader,512,null,&infoLog);
            std.log.err("ERROR SHADER VERTEX COMPILATION FAILED\n{s}\n", .{infoLog});

        }
        const frag_shader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        c.glShaderSource(frag_shader,1,&(&frag_file_buf[0]),null);
        c.glCompileShader(frag_shader);

        infoLog = undefined;

        c.glGetShaderiv(frag_shader, c.GL_COMPILE_STATUS, &success);
        if (success == 0) {
            c.glGetShaderInfoLog(frag_shader,512,null,&infoLog);
            std.log.err("ERROR SHADER FRAGMENT COMPILATION FAILED\n{s}\n", .{infoLog});
        }

        const shader_program = c.glCreateProgram();
        c.glAttachShader(shader_program, vertex_shader);
        c.glAttachShader(shader_program, frag_shader);
        c.glLinkProgram(shader_program);

        c.glGetProgramiv(shader_program, c.GL_LINK_STATUS, &success);
        infoLog = undefined;
        if (success == 0) {
            c.glGetProgramInfoLog(shader_program,512,null,&infoLog);
            std.log.err("ERROR SHADER PROGRAM LINKING FAILED\n{s}\n", .{infoLog});
        }

        c.glDeleteShader(vertex_shader);
        c.glDeleteShader(frag_shader);

        return shader_struct{.id = shader_program};
        

    }

    pub fn use(shader: shader_struct) !void {
        c.glUseProgram(shader.id);
    }

    pub fn set_bool(self: shader_struct, name: [] const u8, value: bool) void {
        c.glUniform1i(c.glGetUniformLocation(self.id,name), @intFromBool(value));
    }
    pub fn set_int(self: shader_struct, name: [] const u8, value: i32) void {
        const c_name: [*c] const u8 = @ptrCast(name);
        c.glUniform1i(c.glGetUniformLocation(self.id,c_name), value);
    }
    pub fn set_float(self: shader_struct, name: [] const u8, value: f32) void {
        const c_name: [*c] const u8 = @ptrCast(name);
        c.glUniform1f(c.glGetUniformLocation(self.id,c_name), value);
    }

    


}; 

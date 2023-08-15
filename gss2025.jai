BUILD : enum { DEVELOPING; DEPLOYING; } : .DEVELOPING;
DEBUG_MEMORY :: BUILD == .DEVELOPING;


my_window: Window_Type;
window_width  : s32 = 1280;
window_height : s32 = 720;

main :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }
    my_window = create_window(window_width, window_height, "Game School Simulator 2025");
    window_width, window_height = Simp.get_render_dimensions(my_window);
    Simp.set_render_target(my_window);

    report := load_assets();
    log("%", report);
    
    last_names := get_text_file("names/last");
    assert(last_names != null);
    //for last_names.* log("%", it);

    init_frame_timer();

    loop_frame_timer(
        process_events=process_events,
        fixed_update=null,
        variable_update=null,
        render=draw_one_frame,
        present=present
    );

    #if DEBUG_MEMORY {
        unload_assets();
        memory_visualizer_per_frame_update();
        report_memory_leaks();
    }
}

process_events :: () {
    Input.update_window_events();
    for Input.get_window_resizes() {
        Simp.update_window(it.window);  // Simp will do nothing if it doesn't care about this window.
        
        if it.window == my_window {
            should_reinit := (it.width != window_width) || (it.height != window_height);

            window_width  = it.width;
            window_height = it.height;

            //if should_reinit my_init_fonts();  // Resize the font for the new window size.
        }
    }
    for Input.events_this_frame {
        if it.type == .QUIT then quit_frame_timer();
        if it.type == {
            case .KEYBOARD;
                if it.key_pressed && it.key_code == .ESCAPE then quit_frame_timer();
        }
    }
}

draw_one_frame :: (dt: float64) {
    Simp.clear_render_target(0, 0, 0, 1);
    Simp.set_shader_for_color();
    time := get_time();
    
    { // rotating square
        b := cast(float)window_height / 10;
        p: Vector2;
        p.x = cast(float)(window_width  / 2);
        p.y = cast(float)(window_height / 2);

        theta := cast(float) fmod_cycling(time, TAU);    

        ct := cos(theta);
        st := sin(theta);
        
        w := Vector2.{b*ct, b*st};
        h := Vector2.{b*st, -b*ct};

        p0 := p - w - h;
        p1 := p + w - h;
        p2 := p + w + h;
        p3 := p - w + h;

        a :: 1.0;
        c0 := Vector4.{1, 0, 0, a};
        c1 := Vector4.{0, 1, 0, a};
        c2 := Vector4.{0, 0, 1, a};
        c3 := Vector4.{1, 1, 1, a};
        
        Simp.immediate_quad(p0, p1, p2, p3, c0, c1, c2, c3);
    }
    { // line drawing
        //immediate_line(.{0,0}, .{100,100}, 4, .{1,1,1,1});
    }
    { // gss2015 logo
        logo := get_texture("logo");
        assert(logo != null);

        Simp.set_shader_for_images(*logo.texture);
        Simp.immediate_begin();

        w := cast(float) window_width/2;
        h := w * cast(float) logo.texture.height / cast(float) logo.texture.width;

        Simp.immediate_quad(.{0, 0}, .{w, 0}, .{w, h}, .{0, h});
        Simp.immediate_flush();
    }
}

present :: () { Simp.swap_buffers(my_window); }

#load "src/Assets.jai";
#load "src/Frame_Timer.jai";
#load "src/Game.jai";

#import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);;
#import "Hash_Table";
#import "Flat_Pool";
Simp :: #import "Simp";
Input :: #import "Input";
#import "Window_Creation";
#import "String";

// super inefficient but whatever for now
immediate_line :: (start: Vector2, end: Vector2, breadth: float, color: Vector4) {
    normalized := unit_vector(end-start);
    rotated_left, rotated_right := normalized;
    rotate(*rotated_left, TAU/4);
    rotate(*rotated_right, -TAU/4);
    half_breadth  := breadth/2;
    rotated_left  *= half_breadth;
    rotated_right *= half_breadth;

    Simp.set_shader_for_color(enable_blend=true);
    Simp.immediate_quad(
        start + rotated_left,
        start + rotated_right,
        end   + rotated_right,
        end   + rotated_left,
        color
    );
}

// immediate circle (using immediate lines)
immediate_circle :: (origin: Vector2, radius: float, breadth: float, segments: int = 12, color: Vector4) {
    delta := TAU / segments;
    for 0..segments-1 {
        next := ifx it == segments-1 then 0 else it+1;
        immediate_line(
            origin + Vector2.{cos(it * delta), sin(it * delta)} * radius,
            origin + Vector2.{cos(next*delta), sin(next*delta)} * radius,
            breadth,
            color
        );
    }
}

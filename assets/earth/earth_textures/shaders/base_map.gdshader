shader_type spatial;

// Basic textures
uniform sampler2D base_tex;            // Base terrain texture
uniform sampler2D height_map;          // Height map for displacement
uniform sampler2D border_mask;         // Border mask texture

// Parameters
uniform float height_scale = 0.1;      // Height map influence
uniform float zoom_min = 10.0;         // Close distance - terrain focused
uniform float zoom_max = 50.0;         // Far distance - borders visible

// Visualization controls
uniform int display_mode = 0;          // 0=Normal, 1=Political, 2+=Debug
uniform float border_intensity = 0.3;  // Border line strength
uniform vec3 border_color = vec3(0.0, 0.0, 0.0);  // Border color
uniform vec3 political_color = vec3(0.8, 0.2, 0.2); // Nation color

void vertex() {
    // Apply height displacement from heightmap
    float h = texture(height_map, UV).r;
    VERTEX += NORMAL * (h * height_scale);
}

void fragment() {
    // Get base color from terrain texture
    vec3 base_color = texture(base_tex, UV).rgb;
    
    // Get border mask data
    vec4 mask_data = texture(border_mask, UV);
    float mask_value = max(max(mask_data.r, mask_data.g), max(mask_data.b, mask_data.a));
    mask_value = 1.0 - mask_value; // Invert mask (borders are dark in texture)
    
    // Camera distance for zoom effects
    float cam_h = length(VIEW_MATRIX[3].xyz);
    float zoom_factor = clamp((cam_h - zoom_min) / (zoom_max - zoom_min), 0.0, 1.0);
    
    vec3 final_color = base_color;
    
    if (display_mode == 0) {
        // Normal mode - terrain with subtle borders
        if (mask_value > 0.1) {
            final_color = mix(final_color, border_color, mask_value * border_intensity * zoom_factor);
        }
    } 
    else if (display_mode == 1) {
        // Political mode - colored regions with borders
        if (mask_value <= 0.1) {
            // Inside regions - political coloring
            final_color = mix(base_color, political_color, 0.7 * zoom_factor);
        } else {
            // Border areas
            final_color = mix(final_color, border_color, mask_value * border_intensity);
        }
    }
    else if (display_mode >= 2) {
        // Debug visualization modes
        int debug_channel = display_mode - 2;
        if (debug_channel == 0) final_color = vec3(mask_data.r, 0.0, 0.0);
        else if (debug_channel == 1) final_color = vec3(0.0, mask_data.g, 0.0);
        else if (debug_channel == 2) final_color = vec3(0.0, 0.0, mask_data.b);
        else if (debug_channel == 3) final_color = vec3(mask_data.a, mask_data.a, mask_data.a);
        else final_color = mask_data.rgb;
    }
    
    ALBEDO = final_color;
}
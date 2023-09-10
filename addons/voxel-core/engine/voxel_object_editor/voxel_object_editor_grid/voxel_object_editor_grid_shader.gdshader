shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color : source_color = vec4(1, 1, 1, 0);

varying vec3 local_normal;

void vertex() {
	// Interpolate vertex normal in local coordinates
	local_normal = NORMAL;
}

void fragment() {
	// Declare albedo color used for the fragment
	vec3 albedo_color = color.rgb;
	
	// Assign axis color if solid color isn't already set
	if (color.a < 1.0) {
		if (local_normal.x > 0.9 || local_normal.x < -0.9) {
			albedo_color = vec3(0, 0, 1);
		} else if (local_normal.y > 0.9 || local_normal.y < -0.9) {
			albedo_color = vec3(0, 1, 0);
		} else if (local_normal.z > 0.9 || local_normal.z < -0.9) {
			albedo_color = vec3(1, 0, 0);
		}
	}
	
	// Calculate the vector from the camera to the fragment's position
	vec3 to_camera = normalize(vec4(VIEW_MATRIX * vec4(CAMERA_POSITION_WORLD, 1)).xyz - VERTEX);
	
	// Calculate the view angle between the camera's view direction and the normal
	float view_angle = dot(normalize(NORMAL), to_camera);
	
	// Set a threshold for visibility (e.g., 0.0 for completely invisible)
	float visibility_threshold = 0.0;
	
	// Check if the line should be rendered
	if (view_angle >= visibility_threshold) {
		discard;
	}
	
	ALBEDO = albedo_color;
}
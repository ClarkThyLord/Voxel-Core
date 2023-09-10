shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color : source_color = vec4(1, 1, 1, 0);

varying vec3 local_normal;

void vertex() {
	local_normal = NORMAL;
}

void fragment() {
	vec3 albedo_color = color.rgb;
	
	if (color.a < 1.0) {
		if (local_normal.x > 0.9 || local_normal.x < -0.9) {
			albedo_color = vec3(0, 0, 1);
		} else if (local_normal.y > 0.9 || local_normal.y < -0.9) {
			albedo_color = vec3(0, 1, 0);
		} else if (local_normal.z > 0.9 || local_normal.z < -0.9) {
			albedo_color = vec3(1, 0, 0);
		}
	}
	
	// Calculate the vector from the camera to the fragment's position.
	vec3 toCamera = ((VIEW_MATRIX * vec4(CAMERA_POSITION_WORLD, 1)) - (VIEW_MATRIX * vec4(MODEL_MATRIX[3].xyz, 1))).xyz;

	// Normalize the toCamera vector.
	toCamera = normalize(toCamera);

	// Calculate the view angle between the camera's view direction and the normal.
	float viewAngle = dot(NORMAL, toCamera);

	// Set a threshold for visibility (e.g., 0.0 for completely invisible).
	float visibilityThreshold = 0.0; // Adjust as needed.

	// Check if the line should be rendered.
	if (viewAngle >= visibilityThreshold) {
		discard;
	}
	
	ALBEDO = albedo_color;
}
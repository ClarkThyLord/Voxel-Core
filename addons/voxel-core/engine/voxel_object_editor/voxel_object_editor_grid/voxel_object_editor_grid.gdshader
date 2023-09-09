shader_type spatial;
render_mode unshaded;


varying vec3 local_normal;

varying vec3 world_normal;

varying vec3 world_position;

void vertex()
{
	local_normal = NORMAL;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 1.0)).xyz);
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 color = vec3(1);
	float threshold = 0.7;
	
	if (local_normal.x > 0.9 || local_normal.x < -0.9) {
		color = vec3(1, 0, 0);
	} else if (local_normal.y > 0.9 || local_normal.y < -0.9) {
		color = vec3(0, 1, 0);
	} else if (local_normal.z > 0.9 || local_normal.z < -0.9) {
		color = vec3(0, 0, 1);
	}
	
	ALBEDO = color;
	
	if (world_normal.x < -threshold) {
		if (world_position.x < CAMERA_POSITION_WORLD.x) {
			discard;
		}
	} else if (world_normal.x > threshold) {
		if (world_position.x > CAMERA_POSITION_WORLD.x) {
			discard;
		}
	} else if (world_normal.y < -threshold) {
		if (world_position.y < CAMERA_POSITION_WORLD.y) {
			discard;
		}
	} else if (world_normal.y > threshold) {
		if (world_position.y > CAMERA_POSITION_WORLD.y) {
			discard;
		}
	} else if (world_normal.z < -threshold) {
		if (world_position.z < CAMERA_POSITION_WORLD.z) {
			discard;
		}
	} else if (world_normal.z > threshold) {
		if (world_position.z > CAMERA_POSITION_WORLD.z) {
			discard;
		}
	} else {
		discard;
	}
}

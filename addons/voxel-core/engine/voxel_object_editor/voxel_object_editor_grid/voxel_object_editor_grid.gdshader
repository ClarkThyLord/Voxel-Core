shader_type spatial;
render_mode unshaded;


varying vec3 world_normal;

varying vec3 world_position;

void vertex()
{
	world_normal = normalize(NORMAL);
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (world_normal.x < -0.9) {
		ALBEDO = vec3(0, 0, 1);
		if (world_position.x < CAMERA_POSITION_WORLD.x) {
			discard;
		}
	} else if (world_normal.x > 0.9) {
		ALBEDO = vec3(0, 0, 1);
		if (world_position.x > CAMERA_POSITION_WORLD.x) {
			discard;
		}
	} else if (world_normal.y < -0.9) {
		ALBEDO = vec3(0, 1, 0);
		if (world_position.y < CAMERA_POSITION_WORLD.y) {
			discard;
		}
	} else if (world_normal.y > 0.9) {
		ALBEDO = vec3(0, 1, 0);
		if (world_position.y > CAMERA_POSITION_WORLD.y) {
			discard;
		}
	} else if (world_normal.z < -0.9) {
		ALBEDO = vec3(1, 0, 0);
		if (world_position.z < CAMERA_POSITION_WORLD.z) {
			discard;
		}
	} else if (world_normal.z > 0.9) {
		ALBEDO = vec3(1, 0, 0);
		if (world_position.z > CAMERA_POSITION_WORLD.z) {
			discard;
		}
	}
}

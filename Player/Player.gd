extends RigidBody2D


const TURN_ACCEL = 16.0
const TURN_DECEL = 16.0
const MAX_ANGULAR_VELOCITY = PI

const MOVE_FORWARD_ACCEL = 256.0
const MOVE_BACK_ACCEL = 128.0
const MOVE_DECEL = 128.0
const MAX_MOVE_VELOCITY = 256.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var step := state.get_step()
	var space_transform := state.get_transform()
	
	# Handle turning.
	var ang_velocity := state.get_angular_velocity()
	
	var turn_left := Input.is_action_pressed(&"turn_left")
	var turn_right := Input.is_action_pressed(&"turn_right")
	
	if turn_left != turn_right:
		if turn_left:
			if ang_velocity > -MAX_ANGULAR_VELOCITY:
				ang_velocity -= TURN_ACCEL * step
		elif turn_right:
			if ang_velocity < MAX_ANGULAR_VELOCITY:
				ang_velocity += TURN_ACCEL * step
	else:
		var abs_vel := absf(ang_velocity)
		abs_vel -= TURN_DECEL * step
		if abs_vel < 0:
			abs_vel = 0
		ang_velocity = signf(ang_velocity) * abs_vel
	
	state.set_angular_velocity(ang_velocity)
	
	# Handle acceleration/deceleration.
	var velocity := state.get_linear_velocity()
	
	var move_forward := Input.is_action_pressed(&"move_forward")
	var move_back := Input.is_action_pressed(&"move_back")
	
	if move_forward != move_back:
		# Forward direction in local space.
		var forward := transform.basis_xform(Vector2(0, -1.0))
		if move_forward:
			if velocity.length_squared() < MAX_MOVE_VELOCITY*MAX_MOVE_VELOCITY:
				velocity = velocity.move_toward(forward * MAX_MOVE_VELOCITY, MOVE_FORWARD_ACCEL * step)
		elif move_back:
			if velocity.length_squared() < MAX_MOVE_VELOCITY*MAX_MOVE_VELOCITY:
				velocity = velocity.move_toward(forward * -MAX_MOVE_VELOCITY, MOVE_BACK_ACCEL * step)
	else:
		velocity = velocity.move_toward(Vector2(), MOVE_DECEL * step)
	
	state.set_linear_velocity(velocity)

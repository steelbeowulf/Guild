extends KinematicBody2D

enum MOVEMENT {idle, left_right, up_down, circle, random}
enum MODE {chasing, returning, moving}
export(int) var id
export(MOVEMENT) var movement = MOVEMENT.idle
export(float) var radius = 0.0
var mode = MODE.moving
onready var map = null
signal battle_notifier

var velocities
var accum = Vector2(0,0)
var state = 0

const SPEED = 150
var velocity = Vector2(0,0)
var base_pos
var my_pos
var chasing = null
var dead = false
var prev_velocity = Vector2(-1,0) # else random gets stuck forever
const tolerance = 0.0

# Initializes speed, position and animation
func _ready():
	velocities = [Vector2(-SPEED, 0), Vector2(0, -SPEED),
				  Vector2(SPEED, 0), Vector2(0, SPEED)]
	base_pos = self.get_global_position()
	map = get_parent().get_parent()
	if id == 11:
		$AnimatedSprite.scale = Vector2(3,3)
	$AnimatedSprite.play(str(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	prev_velocity = velocity
	velocity = Vector2(0,0)
	my_pos = self.get_global_position()
	match mode:
		# Wandering around
		MODE.moving:
			velocity = get_movement(delta)
		
		# Returning to spawn point
		MODE.returning:
			var target_pos = base_pos
			# If i'm close to target, start wandering
			if norm(target_pos - my_pos) < 1:
				mode = MODE.moving
			$View.rotation = (my_pos - target_pos).angle()
			if my_pos.y - target_pos.y > tolerance:
				velocity.y = -SPEED
			if my_pos.y - target_pos.y < tolerance:
				velocity.y = SPEED
			if my_pos.x - target_pos.x > tolerance:
				velocity.x = -SPEED
			if my_pos.x - target_pos.x < tolerance:
				velocity.x = SPEED
		
		# Chasing player
		MODE.chasing:
			var target_pos  = chasing.get_global_position()
			$View.rotation = (my_pos - target_pos).angle()
			if my_pos.y - target_pos.y > tolerance:
				velocity.y = -SPEED
			if my_pos.y - target_pos.y < tolerance:
				velocity.y = SPEED
			if my_pos.x - target_pos.x > tolerance:
				velocity.x = -SPEED
			if my_pos.x - target_pos.x < tolerance:
				velocity.x = SPEED
			velocity*=1.15

	# Deal with animations and FOV angles
	if velocity == Vector2(0,0):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	else:
		if velocity.x > 0:
			$AnimatedSprite.scale.x = -1
		else:
			$AnimatedSprite.scale.x = 1
		$AnimatedSprite.play(str(id))
		if mode == MODE.moving:
			if velocity.x != 0:
				$View.rotation = PI - velocity.angle()
			else:
				$View.rotation = -velocity.angle()

	move_and_slide(velocity)

func get_movement(delta):
	var direction = 1
	match movement:
		MOVEMENT.idle:
			return Vector2(0,0)
		MOVEMENT.left_right:
			if prev_velocity.x >= 0: # Going right
				# Should I keep going?
				if my_pos.x > base_pos.x + radius:
					direction = -1 # Nope, time to go left
			else: # Going left
				# Should I keep going?
				if my_pos.x > base_pos.x - radius:
					direction = -1 # Yep, keep it up
			return Vector2(direction*SPEED, 0)
		MOVEMENT.up_down:
			if prev_velocity.y >= 0: # Going down
				# Should I keep going?
				if my_pos.y > base_pos.y + radius:
					direction = -1 # Nope, time to go up
			else: # Going up
				# Should I keep going?
				if my_pos.y > base_pos.y - radius:
					direction = -1 # Yep keep it up
			return Vector2(0, direction*SPEED)
		MOVEMENT.circle:
			var result
			accum += prev_velocity*delta
			if norm(accum) > radius:
				state += 1
				state = state%4
				accum = Vector2(0,0)
			result = velocities[state]
			return result
		MOVEMENT.random:
			var result = null
			if prev_velocity.x > 0: # Going right
				if my_pos.x < base_pos.x + radius: # Keep going
					result = Vector2(SPEED, 0)
			elif prev_velocity.x < 0: # Going left
				if my_pos.x > base_pos.x - radius: # Keep going
					result = Vector2(-SPEED, 0)
			elif prev_velocity.y > 0: # Going down
				if my_pos.y < base_pos.y + radius: # Keep going
					result = Vector2(0, SPEED)
			else: # Going up
				if my_pos.y > base_pos.y - radius: # Keep going
					result = Vector2(0, -SPEED)
			# Time to decide on a new direction:
			if not result:
				randomize()
				var newdir = floor(rand_range(0,4))
				base_pos = self.get_global_position() # update reference
				result =  velocities[newdir]
			return result


# Player has entered monster's FOV: start chase
func _on_View_body_entered(body):
	if body.is_in_group("player"):
		chasing = body
		mode = MODE.chasing


# Player has left monster's FOV: return to spawn point
func _on_View_body_exited(body):
	if body.is_in_group("player"):
		chasing = null
		mode = MODE.returning


# Function called when monster touches player
# Notifies map to save its state and battle manager
# to start the battle
func _on_Battle_body_entered(body):
	self.dead = true
	if body.is_in_group("player"):
		GLOBAL.entering_battle = true
		map.update_objects_position()
		map.get_node("HUD/Transition").play("Battle")
		yield(map.get_node("HUD/Transition"), "animation_finished")
		BATTLE_MANAGER.initiate_battle()


# Helper function to get norm of a Vector2
func norm(vec):
	return sqrt(vec.x*vec.x + vec.y*vec.y)


# Updates itself according to map state
func _update(value):
	var pos = GLOBAL.parse_position(value[1])
	value = value[0]
	if value:
		self.queue_free()
	self.set_global_position(pos)


# Warns battle manager monster is being seen
func _on_VisibilityNotifier2D_viewport_entered(viewport):
	emit_signal("battle_notifier", true, id, self.get_name())


# Warns battle manager monster is no long being seen
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	emit_signal("battle_notifier", false, id, self.get_name())

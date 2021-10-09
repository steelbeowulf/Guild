extends KinematicBody2D
class_name Car

const aceleration: float = 20.0
var velocity = Vector2(0,0)
#max value for velocity.x and velocity.y
var max_speed = 200.0

# for each delta the car will move
func _physics_process(delta):
	calculate_velocity()
	self.position += velocity
	
# calculate the car's velocity
func calculate_velocity():
	var time = get_physics_process_delta_time()
	velocity.x += aceleration*time
	velocity.x = min(velocity.x, max_speed)
	velocity.y += aceleration*time
	velocity.y = min(velocity.y, max_speed)
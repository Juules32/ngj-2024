extends Node2D
var radius: int = 0
var max_radius = 30
var is_dying = false
@onready var health_component = $HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $"../..".alive: return
	if health_component.is_dying:
		radius -= 1
		if radius <= 0:
			queue_free()
	else:
		radius += 1
	$CollisionShape2D.shape.radius = radius
	radius = min(radius, 30)
	var direction = ($"../..".player_node.position - position).normalized()
	position += direction * 30 * delta

func _draw():
	draw_circle(Vector2(0,0), radius, Color.FIREBRICK)
	for node in $"../..".nodes.get_children():
		if node.position.distance_to(position) < 300:
			draw_line(Vector2(0,0), node.position - position, Color.FIREBRICK, 5)

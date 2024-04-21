extends Node2D

var radius: float = 0
var max_radius = 35
var points = {}
var aoe_radius = 100
var amount_of_dots = 35
@onready var health_component = $HealthComponent

func random_inside_unit_circle() -> Vector2:
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())

func _ready():
	for i in range(amount_of_dots):
		points[random_inside_unit_circle()*aoe_radius] = randi_range(0, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CollisionShape2D.shape.radius = aoe_radius * 0.8
	if health_component.is_dying:
		for key in points:
			if points[key] > 0:
				points[key] -= 0.5
	else:
		for key in points:
			points[key] += (max_radius - points[key]) * 0.0001

func _draw():
	for key in points:
		var radius = points[key]
		draw_circle(key, radius, Color.DARK_OLIVE_GREEN)

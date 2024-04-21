extends Node2D

var range = 120
var radius = 30
var nostalgia: float = 0

@onready var direction_node = $"../../DirectionNode"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	nostalgia += 0.001
	nostalgia = min(nostalgia, 1)

func _draw():
	draw_circle(Vector2(0,0), radius, Color.GREEN)
	draw_circle(Vector2(0,0), nostalgia * radius, Color.GREEN_YELLOW )

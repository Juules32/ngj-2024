extends Node2D

var hp: float = 2000
var max_hp = hp
@onready var root_node = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	if not $"../../..".alive: return
	draw_rect(Rect2(25, -25, root_node.max_nostalgia_charge * 100, 20), Color.WEB_GRAY)
	draw_rect(Rect2(25, -25, root_node.nostalgia_charge * 100, 20), Color.GREEN_YELLOW)
	draw_rect(Rect2(25, -50, max_hp * 0.3, 20), Color.WEB_GRAY)
	draw_rect(Rect2(25, -50, hp * 0.3, 20), Color.RED)
	
	for i in range(root_node.nodes_available):
		draw_circle(Vector2(35 + i * 25, 10), 10, Color.GREEN)
	

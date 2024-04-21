extends Node2D

var Node1 = null
var Node2 = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	if Node1 != null and Node2 != null:
		draw_line(Node1.position, Node2.position, Color.ROYAL_BLUE, 5)
	else:
		queue_free()

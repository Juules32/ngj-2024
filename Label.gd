extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(round_place($"../../..".time_elapsed, 2))

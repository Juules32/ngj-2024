extends Node2D

@export var hp: int
@export var color: Color = Color.RED
@onready var max_hp = hp
@onready var bar_width = float(max_hp) / 8
var is_dying = false
@export var scale_factor = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if hp <= 0:
		is_dying = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if hp >= 0:
		var width = bar_width * scale_factor
		draw_rect(Rect2(-width / 2, width * 0.6, (float(hp) / max_hp) * width, 10), color)

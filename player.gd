extends Node2D
var radius = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $"..".alive: return
	$PlayerArea/CollisionShape2D.shape.radius = radius
	for area in $"LightArea".get_overlapping_areas():
		if $PointLight2D.energy > 0:
			area.health_component.hp -= 3
	
	for area in $PlayerArea.get_overlapping_areas():
		$"../Overlay/Control/UI".hp -= 100 * delta
		$"../Overlay/Control/UI".hp = max($"../Overlay/Control/UI".hp, 0)
		if $"../Overlay/Control/UI".hp <= 0:
			$"../BGM".stop()
			$"..".alive = false
			$"../DeathScreen/VBoxContainer/HBoxContainer/TryAgain".grab_focus()
			$"../DeathScreen".visible = true
			$"../Overlay".visible = false
			
			$"../DeathSound".play()
			$PointLight2D.energy = 0
			$"../DeathScreen/VBoxContainer/Record".text = (
				"After " + $"../Overlay/Control2/TimeElapsed".text + " seconds..."
			)
func _draw():
	draw_circle(Vector2(0,0), radius, Color.YELLOW)

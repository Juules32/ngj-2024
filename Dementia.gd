extends Node2D

var current_node: Node2D = null
var old_node: Node2D = null
var is_moving = false
var radius: float = 0
var max_radius = 30
@onready var health_component = $HealthComponent
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func check_if_alone():
	for edge in $"../..".edges.get_children():
		if edge.Node1 == current_node or edge.Node2 == current_node:
			return false
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $"../..".alive: return
	$CollisionShape2D.shape.radius = 30
	if health_component.is_dying:
		radius -= 1
		if radius <= 0:
			queue_free()
		return
	if not health_component.is_dying:
		health_component.is_dying = check_if_alone()
	if not health_component.is_dying:
		health_component.is_dying = health_component.hp <= 0
	
	radius += 1
	radius = min(radius, 30)
	if is_moving:
		if not is_instance_valid(current_node):
			current_node = $"../..".find_closest_node($".")
		var direction = (current_node.position - position).normalized()
		
		var distance = position.distance_to(current_node.position)

		if distance > 4:
			position += direction * 50 * delta
		else:
			position = current_node.position
			if is_instance_valid(old_node):
				remove_node_and_its_edges(old_node)
			is_moving = false

func remove_node_and_its_edges(node: Node2D):
	for edge in $"../..".edges.get_children():
		if edge.Node1 == node or edge.Node2 == node:
			edge.queue_free()
	node.queue_free()

func _draw():
	draw_circle(Vector2(0,0), radius, Color.WEB_PURPLE)


func _on_destroy_new_node_timeout():
	if not is_moving:
		for edge in $"../..".edges.get_children():
			if edge.Node1 == current_node:
				old_node = current_node
				current_node = edge.Node2
				is_moving = true
				return
			elif edge.Node2 == current_node:
				old_node = current_node
				current_node = edge.Node1
				is_moving = true
				return

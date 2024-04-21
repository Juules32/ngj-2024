extends Node2D

@onready var direction_node = $Player/DirectionNode
@onready var node_scene = load("res://node.tscn")
@onready var edge_scene = load("res://edge.tscn")
@onready var virus_scene = load("res://virus.tscn")
@onready var expander_scene = load("res://expander.tscn")
@onready var dementia_scene = load("res://dementia.tscn")
@onready var nodes = $"Nodes"
@onready var edges = $"Edges"
@onready var current_node = $"Nodes/Node"
@onready var player_node = $Player
@onready var enemies = $Enemies
@onready var nostalgia_ray = $Player/PointLight2D
@onready var original_spawn_time = $EnemyTimer.wait_time
var alive = false
var time_elapsed: float = 0
var max_range = 200
var min_range = 130
var distance_to_mouse: int
var is_moving = false
var nodes_available = 5
var nostalgia_charge: float = 0
var max_nostalgia_charge: float = 6
var shooting_nostalgia = false
var look_for_enemy = false
var wait_for_defeated_enemy = false
var tutorial_finished = false
var first_enemy_spawned = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/VBoxContainer/HBoxContainer/Play.grab_focus()

func find_closest_node(start_node: Node2D):
	var closest_node = null
	var closest_distance = INF
	for node: Node2D in nodes.get_children():
		var distance = start_node.position.distance_to(node.position)
		if distance < closest_distance:
			closest_node = node
			closest_distance = distance
	return closest_node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not alive: return
	
	if look_for_enemy and not tutorial_finished:
		for enemy in enemies.get_children():
			if enemy.position.distance_to(player_node.position) < 250:
				look_for_enemy = false
				show_tutorial_3()
	
	if first_enemy_spawned and not tutorial_finished:
		if len(enemies.get_children()) == 0:
			show_tutorial_4()
			tutorial_finished = true
	
	time_elapsed += delta
	nostalgia_charge -= nostalgia_ray.energy * 0.01
	nostalgia_charge = max(nostalgia_charge, 0)
	
	if nostalgia_charge:
		shooting_nostalgia = Input.is_action_pressed("shoot")
		
		if shooting_nostalgia:
			nostalgia_ray.energy += 0.01
			nostalgia_ray.energy = min(nostalgia_ray.energy, 0.5)
	if not nostalgia_charge or not shooting_nostalgia:
		nostalgia_ray.energy -= 0.01
		nostalgia_ray.energy = max(nostalgia_ray.energy, 0)
	
	if not is_instance_valid(current_node):
		current_node = find_closest_node(player_node)
	nostalgia_charge = min(nostalgia_charge, 10)
	handle_travel()
	handle_enemies()
	
	# Get the input direction and handle the movement/deceleration.
	var x_direction = Input.get_axis("left", "right")
	var y_direction = Input.get_axis("up", "down")
	
	var angle = 0
	if x_direction or y_direction:
		angle = Vector2(0,0).angle_to_point(Vector2(x_direction, y_direction))
		distance_to_mouse = Vector2(0,0).distance_to(Vector2(x_direction, y_direction)) * 100 + min_range
	else:
		angle = player_node.position.angle_to_point(get_global_mouse_position())
		distance_to_mouse = player_node.position.distance_to(get_global_mouse_position())
	distance_to_mouse = min(distance_to_mouse, max_range)
	distance_to_mouse = max(distance_to_mouse, min_range)
	player_node.rotation = angle
	direction_node.position = player_node.position + Vector2(cos(angle), sin(angle)) * distance_to_mouse
	
	var direction = (current_node.position - player_node.position).normalized()
	
	var distance = player_node.position.distance_to(current_node.position)

	if distance > 8:
		player_node.position += direction * 300 * delta
	elif is_moving:
		arrive_at_goal()
		
	queue_redraw()


func _draw():
	var closest_node = null
	var closest_distance = INF
	for node in nodes.get_children():
		var distance = direction_node.position.distance_to(node.position)
		if distance < closest_distance and distance < 120:
			closest_distance = distance
			closest_node = node
	
	if closest_node and not shooting_nostalgia:
		draw_arc(closest_node.position, 120, 0, TAU, 100, Color.WHITE)
	
	if not is_moving and not shooting_nostalgia:
		draw_arc(player_node.position, distance_to_mouse, 0, TAU, 100, Color.WHITE)
		draw_arc(direction_node.position, 30, 0, TAU, 100, Color.WHITE)
	
	draw_enemies()
	
	for node in nodes.get_children():
		node.queue_redraw()
	
	player_node.queue_redraw()

func draw_enemies():
	for enemy in enemies.get_children():
		enemy.queue_redraw()
		enemy.health_component.queue_redraw()


func random_point_on_circle(radius):
	var angle = randf_range(0, 2 * PI)

	var x = radius * cos(angle)
	var y = radius * sin(angle)
	return Vector2(x, y)


func make_dementia():
	print("making new dementia")
	var infected_index = randi_range(0, len(nodes.get_children()) - 1)
	var infected_node = nodes.get_children()[infected_index]
	if infected_node == current_node: 
		print("selected player current node, so no dementia was created")
		return
	var new_enemy = dementia_scene.instantiate()
	new_enemy.current_node = infected_node
	new_enemy.position = new_enemy.current_node.position
	enemies.add_child(new_enemy)

func handle_enemies():
	if Input.is_action_just_pressed("virus"):
		pass

func handle_travel():
	if Input.is_action_just_pressed("travel"):
		if is_moving: return
		var closest_pre_existing_node = null
		var closest_distance = INF
		for node in nodes.get_children():
			if node == current_node: continue
			var distance = direction_node.position.distance_to(node.position)
			if distance < node.range:
				if distance < closest_distance:
					closest_pre_existing_node = node
					closest_distance = distance
		
		if closest_pre_existing_node:
			set_new_goal(closest_pre_existing_node.position)
			add_edge(current_node, closest_pre_existing_node)
			current_node = closest_pre_existing_node
		else:
			try_creating_new_node()
			
func try_creating_new_node():
	if nodes_available <= 0: return
	nodes_available = nodes_available - 1
	var new_node = node_scene.instantiate()
	new_node.position = direction_node.position
	set_new_goal(direction_node.position)
	nodes.add_child(new_node)
	add_edge(current_node, new_node)
	current_node = new_node
			
func add_edge(node1, node2) -> void:
	for edge in edges.get_children():
		if (edge.Node1 == node1 and edge.Node2 == node2) or (edge.Node1 == node2 and edge.Node2 == node1):
			print("edge already exists")
			return
	
	var new_edge = edge_scene.instantiate()
	new_edge.Node1 = node1
	new_edge.Node2 = node2
	edges.add_child(new_edge)
	print("new edge added")

func set_new_goal(position):
	is_moving = true
	
func arrive_at_goal():
	$Pop.play()
	player_node.position = current_node.position
	nostalgia_charge += current_node.nostalgia
	nostalgia_charge = min(nostalgia_charge, max_nostalgia_charge)
	current_node.nostalgia = 0
	is_moving = false
	



func _on_enemy_spawn_speed_timeout():
	if not alive: return
	$EnemyTimer.wait_time -= ($EnemyTimer.wait_time - original_spawn_time*0.1) * 0.05
	$EnemyTimer.wait_time = max($EnemyTimer.wait_time, 0.5)
	print("Time left: ", $EnemyTimer.wait_time)
	if not (not tutorial_finished and tutorial_mode):
		try_spawning_enemy()
	

func try_spawning_enemy():
	if len(enemies.get_children()) > 100: return
	print("spawning enemy")
	var choice = randi_range(1, 3)
	if choice == 3:
		make_virus(500)
	elif choice == 2:
		make_dementia()
	elif choice == 1:
		make_expander()
		
func make_virus(rad):
	var screen_size = get_viewport_rect().size	
	print("making virus")
	var new_enemy = virus_scene.instantiate()
	new_enemy.position = player_node.position + random_point_on_circle(rad)
	enemies.add_child(new_enemy)

func make_expander():
	print("making expander")
	var new_enemy = expander_scene.instantiate()
	new_enemy.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
	enemies.add_child(new_enemy)

func _on_node_recharge_speed_timeout():
	nodes_available = nodes_available + 1


func _on_bgm_finished():
	$"BGM".play()

func _on_try_again_button_down():
	print("restarting game")
	get_tree().reload_current_scene()

func _on_quit_button_down():
	get_tree().quit()

var tutorial_mode = false

func _on_play_button_down():
	alive = true
	tutorial_mode = $Menu/VBoxContainer/HBoxContainer/Tutorial.is_pressed()
	if tutorial_mode:
		nostalgia_charge = 1
		$TutorialTimer1.start()
	$Menu.visible = false


func _on_tutorial_timer_1_timeout():
	$TimerGrabbingFocus.start()
	$TutorialLayer/VBoxContainer/Label.text = "Build your network of memories by moving around\n(Mouse: aim and left-click, Controller: Left joystick and 'X')"
	$TutorialLayer.visible = true
	alive = false

var tutorial_stage = 0

func _on_button_button_down():
	aux()

func aux():
	alive = true
	tutorial_stage += 1
	if tutorial_stage == 1:
		$TutorialTimer2.start()
	if tutorial_stage == 2:
		$TutorialTimer3.start()
		
	if tutorial_stage == 3:
		wait_for_defeated_enemy = true
	$TutorialLayer.visible = false



func _on_tutorial_timer_2_timeout():
	$TimerGrabbingFocus.start()
	$TutorialLayer/VBoxContainer/Label.text = "Your memories generate nostalgia over time\nCollect it to charge your meter"
	$TutorialLayer.visible = true
	alive = false


func show_tutorial_3():
	$TimerGrabbingFocus.start()
	$TutorialLayer/VBoxContainer/Label.text = "An enemy is close! Use your nostalgia to destroy it!\n(Mouse: hold right-click, Controller: 'O' button)"
	$TutorialLayer.visible = true
	alive = false
	
func show_tutorial_4():
	$TimerGrabbingFocus.start()
	$TutorialLayer/VBoxContainer/Label.text = "You destroyed the enemy, good job!\nNow, your goal is to survive for as long as possible"
	$TutorialLayer.visible = true
	alive = false

func _on_tutorial_timer_3_timeout():
	make_virus(500)
	look_for_enemy = true
	first_enemy_spawned = true
	

func _on_tutorial_timer_4_timeout():
	wait_for_defeated_enemy = true


func _on_timer_grabbing_focus_timeout():
	$TutorialLayer/VBoxContainer/Button.grab_focus()

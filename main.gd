extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var grid_pos: Vector2i
var panel_pos: Vector2i
var offset: Vector2i

var temp_mark

var grid_data: Array

var player: int
var board_size: int
var cell_size: int
var moves: int

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	cell_size = board_size / 3
	offset = Vector2i(cell_size / 2, cell_size / 2)
	panel_pos = $Panel.get_position()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x < board_size and event.position.y < board_size:
				grid_pos = Vector2i(event.position / cell_size)
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					grid_data[grid_pos.y][grid_pos.x] = player
					create_marker(player, grid_pos * cell_size + offset)
					moves += 1
					var winner = check_win()
					if winner != 0:
						if winner == 1:
							$GameOverMenu.get_node("WinnerLabel").text = "Player 1 wins!"
						elif winner == -1:
							$GameOverMenu.get_node("WinnerLabel").text = "Player 2 wins!"
						get_tree().paused = true
						$GameOverMenu.show()
					elif moves == 9:
						$GameOverMenu.get_node("WinnerLabel").text = "Draw"
						get_tree().paused = true
						$GameOverMenu.show()
					player *= -1
					if (temp_mark != null): temp_mark.queue_free()
					create_marker(player, panel_pos + offset, true)

func new_game():
	player = 1
	moves = 0
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	create_marker(player, panel_pos + offset, true)
	$GameOverMenu.hide()
	get_tree().paused = false

func create_marker(player, position, flag = false):
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if flag: temp_mark = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if flag: temp_mark = cross

func check_win():
	
	var row_sum: int
	var column_sum: int
	var first_diagonal_sum: int
	var second_diagonal_sum: int
	
	for i in range(3):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		column_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		first_diagonal_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		second_diagonal_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		if row_sum == 3 or column_sum == 3 or first_diagonal_sum == 3 or second_diagonal_sum == 3:
			return 1
		elif row_sum == -3 or column_sum == -3 or first_diagonal_sum == -3 or second_diagonal_sum == -3:
			return -1
	return 0

func _on_game_over_menu_restart():
	new_game()

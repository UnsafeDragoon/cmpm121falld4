## One run at the game: the board and the dragon on it, from the first tick until the
## run ends. Rules that involve more than the dragon (passenger, score, what the dragon can
## run into) belong here, so Dragon stays about movement and app/ only draws.
class_name Session
extends RefCounted

var board: Board
var dragon: Dragon

var passenger: Vector2i = Vector2i(-1, -1)
var score := 0
var rng := RandomNumberGenerator.new()

var started := false
var game_over := false


func _init(grid_size: Vector2i) -> void:
	board = Board.bordered(grid_size)
	dragon = Dragon.new(grid_size)
	rng.seed = 121
	spawn_passenger()


func spawn_passenger() -> void:
	var free_cells: Array[Vector2i] = []

	for cell in board.tiles:
		if not board.is_solid(cell) and cell not in dragon.body:
			free_cells.append(cell)

	if free_cells.is_empty():  #No free space to put passenger
		passenger = Vector2i(-1, -1)
		return

	passenger = free_cells[rng.randi_range(0, free_cells.size() - 1)]


## One step of the rules. TODO for D4: passenger, growth, and collisions with the dragon's
## own body and with solid tiles (board.is_solid). Each needs the dragon and something
## else, which is why they go here rather than in Dragon.tick.
func tick() -> void:
	if not started or game_over:
		return

	var old_body := dragon.body.duplicate()
	var old_tail: Vector2i = dragon.body.back()
	dragon.tick()

	var head: Vector2i = dragon.body[0]

	if board.is_solid(head) or head in dragon.body.slice(1):
		game_over = true
		dragon.body = old_body
		return

	if dragon.body[0] == passenger:
		dragon.body.append(old_tail)
		score += 1
		spawn_passenger()

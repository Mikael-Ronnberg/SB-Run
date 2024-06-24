extends TextureProgress

var player: Player

func set_player(player_instance: Player):
	player = player_instance
	if player != null:
		player.connect("oxygen_change", self, "update")
	update()

func update():
	if player != null:
		value = float(player.oxygen) * 100 / player.MAX_OXYGEN

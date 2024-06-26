extends TextureProgress

var player

func set_player(player_instance):
	player = player_instance
	if player != null:
		player.connect("oxygen_change", self, "update_oxygen")
	update_oxygen(player.oxygen)

func update_oxygen(new_oxygen):
	if player != null:
		value = float(new_oxygen) * 100 / player.MAX_OXYGEN

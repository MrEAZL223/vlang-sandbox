module main

fn set_pixel(position Vector2, type PixelType, mut game Game) {
	game.pixels[position.y][position.x] = type
}

fn get_pixel(position Vector2, game Game)PixelType {
	if position.x < 0 || position.x > game_width - 1 || position.y < 0 || position.y > game_height - 1 {
		return PixelType.none
	}

	return game.pixels[position.y][position.x]
}

fn sand_update(position Vector2, mut game Game) {
	if get_pixel(Vector2{position.x, position.y + 1}, game) == PixelType.air {
		set_pixel(Vector2{position.x, position.y + 1}, PixelType.sand, mut game)
		set_pixel(position, PixelType.air, mut game)
		game.ignore[position.y + 1][position.x] = true
	} else if get_pixel(Vector2{position.x + 1, position.y + 1}, game) == PixelType.air {
		set_pixel(Vector2{position.x + 1, position.y + 1}, PixelType.sand, mut game)
		set_pixel(position, PixelType.air, mut game)
		game.ignore[position.y + 1][position.x + 1] = true
	} else if get_pixel(Vector2{position.x -1, position.y + 1}, game) == PixelType.air {
		set_pixel(Vector2{position.x - 1, position.y + 1}, PixelType.sand, mut game)
		set_pixel(position, PixelType.air, mut game)
		game.ignore[position.y + 1][position.x - 1] = true
	}
}
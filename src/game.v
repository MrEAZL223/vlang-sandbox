module main

import gg
import gx
import time

const game_width = 100
const game_height = 100

const game_fps = 1000 / 60

const pixel_size = 10

type PixelFunction = fn(position Vector2, mut game Game)

struct Vector2 {
mut:
	x int
	y int
}

enum PixelType {
	none = -1
	air
	stone
	sand
}

struct PixelRegister {
mut:
	pixels map[PixelType]PixelFunction
}

struct Game {
mut:
	ctx ?&gg.Context
	pixels [game_height][game_width]PixelType
	ignore [game_height][game_width]bool
	register PixelRegister
	brush PixelType
	last_update time.Time
}

fn init_game(mut ctx gg.Context) {
	mut game := Game{
		pixels: [game_height][game_width]PixelType{init: [game_width]PixelType{init: PixelType.air}}
	}
	
	ctx.user_data = &game
	game.ctx = ctx

	register_pixel(mut game, PixelType.sand, sand_update)

	(game.ctx or {panic("No game context")}).run()
}

fn register_pixel(mut game Game, type PixelType, function PixelFunction) {
	game.register.pixels[type] = function
}

fn update_pixels(mut game Game, mut ctx gg.Context) {
	now := time.now()
	if time.since(game.last_update).milliseconds() < game_fps {
		return
	}
	game.last_update = now

	for py, pixels in game.pixels {
		for px, pixel in pixels {
			if game.ignore[py][px] {
				game.ignore[py][px] = false
				continue
			}

			if function := game.register.pixels[pixel] {
				position := Vector2{px, py}
				function(position, mut game)
			}
		}
	}
}

fn update(mut game Game, mut ctx gg.Context) {
	x := (ctx.mouse_pos_x / pixel_size)
	y := (ctx.mouse_pos_y / pixel_size)

	match ctx.mouse_buttons {
		.left {
			game.pixels[y][x] = game.brush
		}
		.right {
			game.pixels[y][x] = PixelType.air
		}
		else {

		}
	}

	if ctx.pressed_keys[gg.KeyCode._1] {
		game.brush = PixelType.stone
	} else if ctx.pressed_keys[gg.KeyCode._2] {
		game.brush = PixelType.sand
	}

	update_pixels(mut game, mut ctx)
}

fn frame(mut game Game) {
	mut ctx := game.ctx or {panic("No game context")}
	update(mut game, mut ctx)

	ctx.begin()
	draw(mut game, mut ctx)
	ctx.end()
}

fn draw(mut game Game, mut ctx gg.Context) {
	for py, pixels in game.pixels {
		for px, pixel in pixels {
			if pixel in [PixelType.none, PixelType.air] {
				continue
			}

			color := match pixel {
				.stone {
					gx.rgb(70, 70, 70)
				}
				.sand {
					gx.rgb(255, 217, 0)
				} 
				else {
					gx.rgb(0, 0, 0)
				}
			}

			x := px * pixel_size
			y := py * pixel_size

			ctx.draw_square_filled(x, y, pixel_size, color)
		}
	}
}
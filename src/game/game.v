module game

import pixels

import gg
import gx
import time

pub const game_width = 100
pub const game_height = 100
pub const pixel_size = 10

const game_fps = 1000 / 60

struct Game {
mut:
	ctx ?&gg.Context
	pixel_map pixels.PixelMap = pixels.PixelMap{
		[][]pixels.PixelType{len: game_height, init: []pixels.PixelType{len: game_width, init: pixels.PixelType.air}}
		[][]bool{len: game_height, init: []bool{len: game_width, init: false}}
	}
	register pixels.PixelRegister = pixels.register_pixels()
	brush pixels.PixelType = pixels.PixelType.stone
	last_update time.Time
}

pub fn init_game(mut ctx gg.Context) {
	mut game := Game{}
	
	ctx.user_data = &game
	game.ctx = ctx

	(game.ctx or {panic("No game context")}).run()
}

fn update_game(mut game Game, mut ctx gg.Context) {
	now := time.now()
	if time.since(game.last_update).milliseconds() < game_fps {
		return
	}
	game.last_update = now

	mut pmap := game.pixel_map
	mut updates := map[int]map[int]pixels.PixelFunction{}

	for py, pixel_h in pmap.pixels {
		for px, pixel in pixel_h {
			if !pmap.updates[py][px] {
				continue
			}

			if function := game.register.get(pixel) {
				_ := updates[py] or { 
					updates[py] = {}
					updates[py]
				}

				updates[py][px] = function
			}

			pmap.updates[py][px] = false
		}
	}

	for uy, uh in updates {
		for ux, up in uh {
			up(pixels.Vector2{ux, uy}, mut pmap)
		}
	}
}

fn update(mut game Game, mut ctx gg.Context) {
	if ctx.pressed_keys[gg.KeyCode._1] {
		game.brush = pixels.PixelType.stone
	} else if ctx.pressed_keys[gg.KeyCode._2] {
		game.brush = pixels.PixelType.sand
	} else if ctx.pressed_keys[gg.KeyCode._3] {
		game.brush = pixels.PixelType.water
	}

	x := (ctx.mouse_pos_x / pixel_size)
	y := (ctx.mouse_pos_y / pixel_size)

	mut pmap := game.pixel_map
	if y >= 0 && y < pmap.pixels.len - 1 && x >= 0 && x < pmap.pixels[0].len {
		pos := pixels.Vector2{x, y}

		match ctx.mouse_buttons {
			.left {
				pmap.set_pixel(pos, game.brush)
			}
			.right {
				pmap.set_pixel(pos, pixels.PixelType.air)
			}
			else {

			}
		}
	}

	update_game(mut game, mut ctx)
}

fn frame(mut game Game) {
	mut ctx := game.ctx or {panic("No game context")}
	update(mut game, mut ctx)

	ctx.begin()
	draw(mut game, mut ctx)
	ctx.end()
}

fn draw(mut game Game, mut ctx gg.Context) {
	mut pmap := game.pixel_map
	for py, pixel_h in pmap.pixels {
		for px, pixel in pixel_h {
			if pixel in [pixels.PixelType.none, pixels.PixelType.air] {
				continue
			}

			color := match pixel {
				.stone {
					gx.rgb(70, 70, 70)
				}
				.sand {
					gx.rgb(255, 217, 0)
				} 
				.water {
					gx.rgb(100, 150, 255)
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
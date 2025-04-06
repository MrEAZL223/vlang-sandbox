module main

import game

import gg
import gx

fn main() {
	mut ctx := gg.new_context(
		bg_color: gx.rgb(255, 255, 255)
		width: game.game_width * game.pixel_size
		height: game.game_height * game.pixel_size
		window_title: 'VLang'
		frame_fn: game.frame
	)

	game.init_game(mut ctx)
}
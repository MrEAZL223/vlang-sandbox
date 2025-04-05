module main

import gg
import gx

fn main() {
	mut ctx := gg.new_context(
		bg_color: gx.rgb(255, 255, 255)
		width: game_width * pixel_size
		height: game_height * pixel_size
		window_title: 'VLang'
		frame_fn: frame
	)

	init_game(mut ctx)
}
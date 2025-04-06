module pixels

pub type PixelFunction = fn(position Vector2, mut pmap PixelMap)

pub enum PixelType {
	none = -1
	air
	stone
	sand
	water 
}

pub struct PixelRegister {
mut:
	pixels map[PixelType]PixelFunction
}

pub struct PixelMap {
pub mut:
	pixels [][]PixelType
	updates [][]bool
}

pub fn (mut self PixelMap) set_update(x int, y int) {
	if x < 0 || x > self.pixels[0].len - 1 || y < 0 || y > self.pixels.len - 1 {
		return
	}

	self.updates[y][x] = true
}

pub fn (mut self PixelMap) set_pixel(position Vector2, type PixelType) {
	self.pixels[position.y][position.x] = type

	self.set_update(position.x, position.y)
	self.set_update(position.x-1, position.y)
	self.set_update(position.x+1, position.y)
	self.set_update(position.x, position.y+1)
	self.set_update(position.x, position.y-1)
	self.set_update(position.x-1, position.y+1)
	self.set_update(position.x+1, position.y+1)
	self.set_update(position.x-1, position.y-1)
	self.set_update(position.x+1, position.y-1)
}

pub fn (self PixelMap) get_pixel(position Vector2)PixelType {
	if position.x < 0 || position.x > self.pixels[0].len - 1 || position.y < 0 || position.y > self.pixels.len - 1 {
		return PixelType.none
	}

	return self.pixels[position.y][position.x]
}

fn (mut self PixelRegister) register(type PixelType, function PixelFunction) {
	self.pixels[type] = function
}

pub fn (self PixelRegister) get(type PixelType) ?PixelFunction {	
	return self.pixels[type] or { none }
}

pub fn register_pixels()PixelRegister {
	mut register := PixelRegister{}
	register.register(PixelType.sand, sand_update)
	register.register(PixelType.water, water_update)

	return register
}

fn sand_update(position Vector2, mut pmap PixelMap) {
	below := pmap.get_pixel(Vector2{position.x, position.y + 1})
	if below in [PixelType.air, PixelType.water] {
		pmap.set_pixel(Vector2{position.x, position.y + 1}, PixelType.sand)
		pmap.set_pixel(position, below)
	} else if pmap.get_pixel(Vector2{position.x + 1, position.y + 1}) == PixelType.air {
		pmap.set_pixel(Vector2{position.x + 1, position.y + 1}, PixelType.sand)
		pmap.set_pixel(position, PixelType.air)
	} else if pmap.get_pixel(Vector2{position.x -1, position.y + 1}) == PixelType.air {
		pmap.set_pixel(Vector2{position.x - 1, position.y + 1}, PixelType.sand)
		pmap.set_pixel(position, PixelType.air)
	}
}

fn water_update(position Vector2, mut pmap PixelMap) {
	if pmap.get_pixel(Vector2{position.x, position.y + 1}) == PixelType.air {
		pmap.set_pixel(Vector2{position.x, position.y + 1}, PixelType.water)
		pmap.set_pixel(position, PixelType.air)
	} else if pmap.get_pixel(Vector2{position.x + 1, position.y}) == PixelType.air {
		pmap.set_pixel(Vector2{position.x + 1, position.y}, PixelType.water)
		pmap.set_pixel(position, PixelType.air)
	} else if pmap.get_pixel(Vector2{position.x -1, position.y}) == PixelType.air {
		pmap.set_pixel(Vector2{position.x - 1, position.y}, PixelType.water)
		pmap.set_pixel(position, PixelType.air)
	}
}
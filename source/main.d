import std.stdio;
import core.thread;
import core.time;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import render;
import game;

const string BASE_PATH = "./res/";

void main() {
	DerelictSDL2.load();
	DerelictSDL2Image.load();

	SDL_Init(SDL_INIT_VIDEO);
	
	SDL_Window* win = SDL_CreateWindow("000", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH * SCALE, HEIGHT * SCALE, SDL_WINDOW_SHOWN);
	SDL_Surface* winSurf = SDL_GetWindowSurface(win);
	
	game.init();
	render.init();
	
	uint current = SDL_GetTicks();
	uint last = current;
	double delta = 0;
	int frames = 0, lastSecond = current;
	while (!SDL_QuitRequested()) {
		last = current;
		current = SDL_GetTicks();
		delta = (current - last) / 1000.0;
		
		game.tick(delta);
		try {
			render.tick();
		}catch (Exception e) {
			writeln(e.msg);
			break;
		}
		
		for (int x = 0; x < WIDTH * SCALE; x++) 
			for (int y = 0; y < HEIGHT * SCALE; y++) {
				uint* pix = (cast(uint*) winSurf.pixels) + x + y * winSurf.pitch / uint.sizeof;
				*pix = render.pixels[x / SCALE + y / SCALE * WIDTH][0] << 16;
				*pix |= render.pixels[x / SCALE + y / SCALE * WIDTH][1] << 8;
				*pix |= render.pixels[x / SCALE + y / SCALE * WIDTH][2];
			}
		
		SDL_UpdateWindowSurface(win);
		
		frames++;
		if (current - lastSecond > 1000) {
			lastSecond = current;
			writeln("FPS: ", frames);
			frames = 0;
		}
	}
	
	game.quit();
	render.quit();
	
	SDL_Quit();
}


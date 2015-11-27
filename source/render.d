import std.stdio;
import std.math;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import game;
import entity;
import main;

enum uint SCALE = 3;
enum uint WIDTH = 160;
enum uint HEIGHT = 120;

immutable uint TILE_SIZE = 8;

immutable uint ALPHA_COLOR = 0xFF00FF;

ubyte[3][WIDTH * HEIGHT] pixels;
private float[WIDTH] xAngles;
private float[HEIGHT] yAngles;

double fov, vFov, texSize;

bool ceiling = false;

private {
	double[2] rot = [1000, 1000];
	double[WIDTH] xCos, xTan;
}

Sprite spr, backdrop;

class Sprite {
	ubyte[][] pixels;
	immutable uint w, h;
	
	this(uint w, uint h) {
		pixels = new ubyte[][](w * h, 3);
		this.w = w;
		this.h = h;
		for (int i = 0; i < w * h; i++) 
			for (int j = 0; j < 3; j++)
				pixels[i][j] = cast(ubyte) (i * 0xFF / w / h);
	}

	this(string path) {
		SDL_Surface* s = IMG_Load((std.string.toStringz(main.BASE_PATH ~ path)));
		if (s == null) {
			writeln("Failed to load image: ", path);
			throw new Exception("Couldn't find resource. ");
		}
		
		w = s.w;
		h = s.h;
		pixels = new ubyte[][](w * h, 3);

		for (int x = 0; x < w; x++) 
			for (int y = 0; y < h; y++) 
				for (int j = 0; j < 3; j++) 
					pixels[x + y * w][j] = cast(ubyte) ((cast(uint*)s.pixels)[x + y * s.pitch / uint.sizeof] >> (16 - 8 * j));
	}
	
    ref ubyte[] opIndex(int x, int y) {
		return pixels[x + y * w];
    }
}

void init() {
	for (int x = 0; x < WIDTH; x++)
		for (int y = 0; y < HEIGHT; y++) 
			for (int j = 0; j < 3; j++) 
				pixels[x + y * WIDTH][j] = 0;
	
	fov = 50 / 180.0 * PI;
	vFov = fov * HEIGHT / WIDTH;
	texSize = 0.2;
	
	for (int x = 0; x < WIDTH; x++) 
		xAngles[x] = (x - WIDTH / 2.0) / WIDTH * fov;
	
	for (int y = 0; y < HEIGHT; y++) 
		yAngles[y] = (y - HEIGHT / 2.0) / HEIGHT * vFov;
	
	backdrop = new Sprite("Backdrop.png");
	spr = new Sprite("Cobble.png");
	if (spr.w != TILE_SIZE || spr.h != TILE_SIZE) throw new Exception("Incorrect sprite size! ");
}

void tick() {
	double[] times;
	times ~= main.getTime();

	if (rot[0] != game.rot[0] || rot[1] != game.rot[1]) {
		rot[0] = game.rot[0];
		rot[1] = game.rot[1];
		for (int x = 0; x < WIDTH; x++) {
			xCos[x] = cos(xAngles[x] + game.rot[1]);
			xTan[x] = tan(xAngles[x] + game.rot[1]);
		}
	}

	for (int y = 0; y < HEIGHT; y++) {
		double zLocal = 1.0 / (abs(tan(yAngles[y] + game.rot[0])) / game.pos[1]);
		if (zLocal > 50 || (!ceiling && y < HEIGHT / 2)) {
			for (int x = 0; x < WIDTH; x++) 
				pixels[x + y * WIDTH][0..3] = backdrop[x * backdrop.w / WIDTH, y * backdrop.h / HEIGHT][0..3];
			continue;
		}
		
		for (int x = 0; x < WIDTH; x++) {
			double zz = zLocal * xCos[x];
			double xx = xTan[x] * zz;
			
			int zWorld = cast(int) ((zz - game.pos[2]) / texSize);
			int xWorld = cast(int) ((xx + game.pos[0]) / texSize);
			
			pixels[x + y * WIDTH][0..3] = spr[xWorld & 0b111, zWorld & 0b111][0..3];
		}
	}

	times ~= main.getTime();

	foreach (e; game.ents) {
		auto s = e.spr;

		double dx = e.x - game.pos[0];
		double dy = e.z - game.pos[2];
		if (dx > 0.5 || dx < -0.5 || dy > 0.5 || dy < -0.5) {
			double d = sqrt(dx * dx + dy * dy);
			double xa = atan2(dy, dx) - game.rot[1] + PI / 2.0;
			double ya = -atan2(e.y - game.pos[1], d);
			double xm = cast(int) (xa / fov * WIDTH);
			double yb = cast(int) (ya / vFov * HEIGHT);
			double yt = cast(int) (-atan2(e.y + e.height - game.pos[1], d) / vFov * HEIGHT);
			double xd = (yb - yt) / s.h * s.w / 2;
			for (double x = xm - xd; x < xm + xd; x++) 
				for (double y = yt; y < yb; y++) {
					int xs = cast(int) ((x - xm + xd) / 2 / xd * s.w);
					int ys = cast(int) ((y - yt) / (yb - yt) * s.h);
					if (s[xs, ys][0] == cast(ubyte) (ALPHA_COLOR >> 16) 
						&& s[xs, ys][1] == cast(ubyte) (ALPHA_COLOR >> 8) 
						&& s[xs, ys][2] == cast(ubyte) ALPHA_COLOR) continue; 
					int xx = cast(int) (x);
					int yy = cast(int) (y);
					if (abs(xx) + 1 > WIDTH / 2) continue;
					if (abs(yy) + 1 > HEIGHT / 2) continue;
					setPixel(WIDTH / 2 + xx, HEIGHT / 2 + yy, s[xs, ys][0], s[xs, ys][1], s[xs, ys][2]);
				}
		}
	}
	
	times ~= main.getTime();

	addTime(times);
}

void setPixel(int x, int y, int r, int g, int b) {
	pixels[x + y * WIDTH][0] = cast(ubyte) r;
	pixels[x + y * WIDTH][1] = cast(ubyte) g;
	pixels[x + y * WIDTH][2] = cast(ubyte) b;
}

void setPixel(int x, int y, int r, int g, int b, double a) {
	double aa = 	1 - a;
	pixels[x + y * WIDTH][0] = cast(ubyte) (r * a + pixels[x + y * WIDTH][0] * aa);
	pixels[x + y * WIDTH][1] = cast(ubyte) (g * a + pixels[x + y * WIDTH][1] * aa);
	pixels[x + y * WIDTH][2] = cast(ubyte) (b * a + pixels[x + y * WIDTH][2] * aa);
}

void quit() {
}

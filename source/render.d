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

immutable uint ALPHA_COLOR = 0xFF00FF;

ubyte[3][WIDTH * HEIGHT] pixels;
private float[WIDTH] xAngles;
private float[HEIGHT] yAngles;

double fov, vFov, texSize;

bool ceiling = false;

Sprite spr;

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
	
	spr = new Sprite("Cobble.png");
}

void tick() {
	for (int i = 0; i < WIDTH * HEIGHT; i++) 
		for (int j = 0; j < 3; j++) 
			pixels[i][j] = 0;

	for (int y = ceiling ? 0 : HEIGHT / 2; y < HEIGHT; y++) {
		double zLocal = 1.0 / (abs(tan(yAngles[y] + game.rot[0])) / game.pos[1]);
		if (zLocal > 50) continue;
		
		for (int x = 0; x < WIDTH; x++) {
			double xCos = cos(xAngles[x] + game.rot[1]);
			double zz = zLocal * xCos;
			double xx = tan(xAngles[x] + game.rot[1]) * zz;
			
			double zWorld = zz - game.pos[2];
			double xWorld = xx + game.pos[0];
			
			int u = cast(int) abs(cast(int) (xWorld / texSize) % spr.w);
			int v = cast(int) abs(zWorld / texSize % spr.h);
			
			setPixel(x, y, spr[u, v][0], spr[u, v][1], spr[u, v][2]);
		}
	}

	auto e = game.post;
	auto s = e.spr;

	double dx = game.post.x - game.pos[0];
	double dy = game.post.z - game.pos[2];
	if (dx > 0.5 || dx < -0.5 || dy > 0.5 || dy < -0.5) {
		double d = sqrt(dx * dx + dy * dy);
		double xa = atan2(dy, dx) - game.rot[1] + PI / 2.0;
		while (xa > PI) xa -= 2 * PI;
		while (xa < -PI) xa += 2 * PI;
		double ya = -atan2(e.y - game.pos[1], d);
		/*for (int x = 0; x < s.w; x++) 
			for (int y = 0; y < s.h; y++) {
				int xx = cast(int) (xa / fov * WIDTH) + cast(int) ((x - s.w / 2) / d);
				int yy = cast(int) (ya / vFov * HEIGHT) + cast(int) ((y - s.h) / d);
				if (abs(xx) + 1 > WIDTH / 2) return;
				if (abs(yy) + 1 > HEIGHT / 2) return;
				setPixel(WIDTH / 2 + xx, HEIGHT / 2 + yy, s[x, y][0], s[x, y][1], s[x, y][2]);
			}*/
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

void setPixel(int x, int y, int r, int g, int b) {
	pixels[x + y * WIDTH][0] = cast(ubyte) r;
	pixels[x + y * WIDTH][1] = cast(ubyte) g;
	pixels[x + y * WIDTH][2] = cast(ubyte) b;
}

void quit() {
}

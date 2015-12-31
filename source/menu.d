import render;
import input;
import game;
import std.stdio;
import std.math;
import std.algorithm.comparison;

interface Component {
	void event();
	void render();
	bool isInteractive();
}

class Menu {
	Component[] comps;
	
	this(Component[] c) {
		comps ~= c;
	}
	
	void event() {
		foreach (Component c; comps) 
			if (c.isInteractive()) c.event();
	}
	
	void render() {
		for (int i = cast(int) comps.length - 1; i >= 0; i--) 
			comps[i].render();
	}
}

struct MenuItem {
	string name;
	Menu link;
}

Menu current;

Menu mainMenu, hudMenu;

Sprite title;

void init() {
	title = new Sprite("Title.png");

	hudMenu = new Menu(cast(Component[]) [new Controller(), new WeaponRenderer()]);
	mainMenu = new Menu(cast(Component[]) [
		new Image(title, WIDTH / 2, HEIGHT / 3), 
		new MController(cast(MenuItem[]) [
			MenuItem("Play", hudMenu),
			MenuItem("Fuck off", null)
		], WIDTH / 2, HEIGHT / 2, HEIGHT * 4 / 5)
	]);
	
	current = mainMenu;
}

class Image : Component {
	private Sprite s;
	private int x, y, w, h;
	
	this(Sprite s, int x, int y, int w, int h) {
		this.s = s;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
	
	this(Sprite s, int x, int y) {
		this.s = s;
		this.x = x - s.w / 2;
		this.y = y - s.h / 2;
		this.w = s.w;
		this.h = s.h;
	}

	void event() {}
	
	void render() {
		draw(s, x, y, w, h);
	}
	
	bool isInteractive() { return false; }
}

// Enables menu navigation
class MController : Component {
	private int selected = 0, xCoord, yMin, yMax;
	private bool upHeld = false, downHeld = false;
	private MenuItem[] items;
	
	this(MenuItem[] items, int xCoord, int yMin, int yMax) {
		this.items = items;
		this.xCoord = xCoord;
		this.yMin = yMin;
		this.yMax = yMax;
	}

	void event() {
		if (input.isPressed(W)) {
			if (!upHeld) {
				upHeld = true;
				selected--;
			}
		}else upHeld = false;
		if (input.isPressed(S)) {
			if (!downHeld) {
				downHeld = true;
				selected++;
			}
		}else downHeld = false;
		
		if (selected < 0) selected = 0;
		if (selected >= items.length) selected = cast(int) items.length - 1;
		
		if (input.isPressed(SELECT) && items[selected].link !is null) 
			current = items[selected].link;
	}
	
	void render() {
		// The number of steps between yMin and yMax
		int num = cast(int) (items.length > 1 ? items.length - 1 : 1);
		
		for (int i = 0; i < items.length; i++) {
			auto x = xCoord;
			auto y = yMin + i * (yMax - yMin) / num;
			auto s = items[i].name;
			
			// Draw a border around the selected option
			if (selected == i) 
				setPixels(
					x - s.length * fontCharWidth / 2 - 1, 
					y - fontCharHeight / 2 - 1, 
					s.length * fontCharWidth + 2, 
					fontCharHeight + 2, 0xA0, 0xA0, 0xA0);
		
			// Draw the items text
			drawString(items[i].name, 
				xCoord, cast(int) (yMin + i * (yMax - yMin) / num), 
				[0x30, 0x30, 0x30]
			);
		}
	}
	
	bool isInteractive() { return true; }
	
	int getSelected() { return selected; }
}

// Enables player movement
class Controller : Component {
	private bool attackHeld = false;

	void event() {
		bool attack = input.isPressed(ATTACK);
		double dTime = main.getTime() - p.e.lastFired;
		if (attack 
			&& (p.e.weapon.automatic ? dTime > p.e.weapon.firerate : !attackHeld)) 
			game.p.e.fire();
		attackHeld = attack;
		
		double[] dR = [0, 0];
		if (input.isPressed(LEFT)) dR[1] -= game.delta;
		if (input.isPressed(RIGHT)) dR[1] += game.delta;
	
		double[] d = [0, 0, 0];
		if (input.isPressed(W)) d[2] -= game.delta;
		if (input.isPressed(S)) d[2] += game.delta;
		if (input.isPressed(A)) d[0] -= game.delta;
		if (input.isPressed(D)) d[0] += game.delta;
		if (d[0] != 0 && d[2] != 0) {
			d[0] /= 1.41; // √2
			d[2] /= 1.41;
		}
		
		p.e.rotate(dR);
		p.e.move(d);
	}
	
	void render() {}
	
	bool isInteractive() { return true; }
}

class WeaponRenderer : Component {
	private float xOffs = 0;
	private immutable int limit = 40, speed = 256;
	private immutable float rubberband = 1.0 / 2048;

	void event() {}
	
	void render() {
		xOffs -= game.p.e.dyRot * speed;
		if (xOffs > limit) xOffs = limit;
		if (xOffs < -limit) xOffs = -limit;
		xOffs *= pow(rubberband, game.delta);
		
		Sprite[] s = game.p.e.weapon.spr;
		double x = (main.getTime() - game.p.e.lastFired) / game.p.e.weapon.firerate;
		double f = expression([[1 / 0.7, 0.3], [-1 / 0.7, 1.5]], x / 0.3);
		f = clamp(f, 0, 1);
		int index = cast(int) (f * s.length);
		if (index >= s.length) index = cast(int) (s.length - 1);
		if (s.length > 0) {
			double scale = cast(double) HEIGHT / s[0].h;
			draw(s[index], cast(uint) (WIDTH / 2 - s[0].w / 2 * scale + xOffs), 0, 
				cast(uint) (s[0].w * scale), HEIGHT);
		}
	}
	
	bool isInteractive() { return false; }
}


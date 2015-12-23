import render;
import input;
import game;
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

Menu current;

Menu mainMenu, hudMenu;

Sprite title;

void init() {
	title = new Sprite("Title.png");

	mainMenu = new Menu([new Image(title, WIDTH / 2, HEIGHT / 3)]);
	hudMenu = new Menu(cast(Component[]) [new Controller(), new WeaponRenderer()]);
	
	current = hudMenu;
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


import render;
import input;
import game;

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
			c.event();
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
	hudMenu = new Menu([new Controller()]);
	
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
	void event() {
		double[] dR = [0, 0];
		if (input.isPressed(LEFT)) dR[1] -= game.delta;
		if (input.isPressed(RIGHT)) dR[1] += game.delta;
	
		double[] d = [0, 0, 0];
		if (input.isPressed(W)) d[2] -= game.delta;
		if (input.isPressed(S)) d[2] += game.delta;
		if (input.isPressed(A)) d[0] -= game.delta;
		if (input.isPressed(D)) d[0] += game.delta;
		if (d[0] != 0 && d[2] != 0) {
			d[0] /= 1.41;
			d[2] /= 1.41;
		}
		
		p.e.rotate(dR);
		p.e.move(d);
	}
	
	void render() {}
	
	bool isInteractive() { return true; }
}


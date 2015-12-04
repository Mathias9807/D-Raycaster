import render;

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

Menu mainMenu;

Sprite title;

void init() {
	title = new Sprite("Title.png");

	mainMenu = new Menu([new Image(title, WIDTH / 2, HEIGHT / 3)]);
	
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


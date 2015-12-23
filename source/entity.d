import render;
import ai;
import std.math;

struct Weapon {
	string name;
	Sprite[] spr;
	
	// Weapon stats
	int firerate;
	bool automatic;
	
	Bullet b;
}

class Entity {
	public double x, y, z;
	public double xRot, yRot, dxRot, dyRot;
	public double height, speed, rotSpeed;

	public Sprite spr;

	this(double x, double y, double z, double h, Sprite s) {
		this.x = x;
		this.y = y;
		this.z = z;
		xRot = 0;
		yRot = 0;
		height = h;
		speed = 5;
		rotSpeed = 1.2;
		this.spr = s;
	}
	
	public void tick(double delta) {}
}

class Bullet : Entity {
	public double dx, dy, dz, speed;
	
	this(double x, double y, double z, double h, Sprite s) {
		super(x, y, z, h, s);
		
		dx = dy = dz = speed = 0;
	}
	
	// Copy constructor for firing a prespecified bullet
	this(Bullet b, double x, double y, double z) {
		this(x, y, z, b.height, b.spr);
	}
	
	override public void tick(double delta) {
		x += dx * delta;
		y += dy * delta;
		z += dz * delta;
	}
}

class Mob : Entity {
	public double dx, dy, dz, dxRot, dyRot;
	public double eyeHeight;
	public Weapon weapon;
	public double lastFired;
	
	public Routine ai;
	
	this(double x, double y, double z, double h, Sprite s, Routine r) {
		super(x, y, z, h, s);
		
		weapon = game.weps[0];
		lastFired = main.getTime();
		eyeHeight = h * 2 / 3;
		dx = dy = dz = 0;
		dxRot = dyRot = 0;
		ai = r;
	}
	
	override public void tick(double delta) {
		if (ai !is null) ai.run(this);
	}
	
	public void fire() {
		lastFired = main.getTime();
		
		auto blast = new Bullet(weapon.b, x, y + eyeHeight - 0.35, z);
		blast.dx = cos(yRot - PI / 2) * 24;
		blast.dz = sin(yRot - PI / 2) * 24;
		game.ents ~= blast;
	}
	
	public void move(double[] delta) {
		for (int i = 0; i < delta.length; i++) 
			delta[i] *= speed;
		
		double cosine = cos(yRot), sine = sin(yRot);
		
		x += cosine * delta[0] - sine * delta[2];
		y += delta[1];
		z += cosine * delta[2] + sine * delta[0];
		
		dx = delta[0];
		dy = delta[1];
		dz = delta[2];
	}
	
	public void rotate(double[] delta) {
		xRot += delta[0];
		yRot += delta[1];
		
		while (yRot >= 2 * PI) yRot -= 2 * PI;
		while (yRot < -2 * PI) yRot += 2 * PI;
		
		dxRot = delta[0];
		dyRot = delta[1];
	}
}


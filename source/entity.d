import render;
import std.math;

struct Weapon {
	string name;
	Sprite[] spr;
}

class Entity {
	public double x, y, z, dx, dy, dz;
	public double xRot, yRot, dxRot, dyRot;
	public double height, eyeHeight, speed, rotSpeed;

	public Sprite spr;
	
	public Weapon weapon;

	this(double x, double y, double z, double h, Sprite s) {
		this.x = x;
		this.y = y;
		this.z = z;
		dx = dy = dz = 0;
		xRot = 0;
		yRot = 0;
		dxRot = dyRot = 0;
		height = h;
		eyeHeight = h * 2 / 3;
		speed = 5;
		rotSpeed = 1.2;
		this.spr = s;
		weapon = game.weps[0];
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


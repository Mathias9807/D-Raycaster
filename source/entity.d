import render;
import std.math;

class Entity {
	
	public double x, y, z;
	public double xRot, yRot;
	public double height, eyeHeight, speed, rotSpeed;

	public Sprite spr;

	this(double x, double y, double z, double h, Sprite s) {
		this.x = x;
		this.y = y;
		this.z = z;
		xRot = 0;
		yRot = 0;
		height = h;
		eyeHeight = h * 2 / 3;
		speed = 5;
		rotSpeed = 1.2;
		this.spr = s;
	}
	
	public void move(double[] delta) {
		for (int i = 0; i < delta.length; i++) 
			delta[i] *= speed;
		
		double cosine = cos(yRot), sine = sin(yRot);
		
		x += cosine * delta[0] - sine * delta[2];
		y += delta[1];
		z += cosine * delta[2] + sine * delta[0];
	}
	
	public void rotate(double[] delta) {
		xRot += delta[0];
		yRot += delta[1];
		
		while (yRot >= 2 * PI) yRot -= 2 * PI;
		while (yRot < -2 * PI) yRot += 2 * PI;
	}
	
}

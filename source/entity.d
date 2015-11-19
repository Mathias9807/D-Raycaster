import render;

class Entity {
	
	public double x, y, z;
	public double height;

	public Sprite spr;

	this(double x, double y, double z, double h, Sprite s) {
		this.x = x;
		this.y = y;
		this.z = z;
		height = h;
		this.spr = s;
	}
	
}

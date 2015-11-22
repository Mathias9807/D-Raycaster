import input;
import entity;
import render;
import std.math;

double[3] pos = [0, 1, 0];
double[2] rot = [0, 0];
double speed = 5, rotSpeed = 1.2;

Entity[] ents;

void init() {
	ents ~= new Entity(0, 0, 0, 0.4, new Sprite("Thrash.png"));
}

void tick(double delta) {	
	if (input.isPressed(LEFT)) rot[1] -= delta * rotSpeed;
	if (input.isPressed(RIGHT)) rot[1] += delta * rotSpeed;

	double[] d = [0, 0, 0];
	if (input.isPressed(W)) d[2] -= delta * speed;
	if (input.isPressed(S)) d[2] += delta * speed;
	if (input.isPressed(A)) d[0] -= delta * speed;
	if (input.isPressed(D)) d[0] += delta * speed;
	if (d[0] != 0 && d[2] != 0) {
		d[0] /= 1.41;
		d[2] /= 1.41;
	}
	double cosine = cos(rot[1]), sine = sin(rot[1]);
	pos[0] += cosine * d[0] - sine * d[2];
	pos[2] += cosine * d[2] + sine * d[0];
}

void quit() {
}


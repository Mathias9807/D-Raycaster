import input;
import entity;
import render;
import menu;
import std.stdio;
import std.math;
import std.conv;
import std.algorithm;

double delta;

struct Player {
	Mob e; // The entity this player is controlling
}

Weapon[] weps;
Entity[] ents;
Player p;

void init() {
	weps ~= Weapon("Unarmed", [], 1, false);
	Sprite[] s;
	for (int i = 1; i <= 8; i++) 
		s ~= new Sprite("Blaster/000" ~ to!string(i) ~ ".png");
	weps ~= Weapon("Blaster", s, 1, false);

	p.e = new Mob(0, 0, 0, 1.8, new Sprite("Thrash.png"));
	ents ~= p.e;
	
	p.e.weapon = weps[1];
}

void tick(double delta) {	
	game.delta = delta;
	
	foreach (Entity e; ents) 
		e.tick(delta);

	menu.current.event();
	
	auto pX = to!string(p.e.x);
	auto pZ = to!string(p.e.z);
	auto sortMethod(Entity a, Entity b) @safe nothrow {
		return abs(a.x - p.e.x) + abs(a.z - p.e.z) > abs(b.x - p.e.x) + abs(b.z - p.e.z);
	}
	sort!(sortMethod, SwapStrategy.stable)(ents);
}

double polynomial(double[] coeffs, double x) {
	double result = 0;
	
	for (int i = 0; i < coeffs.length; i++) {
		result += coeffs[i] * pow(x, i);
	}
	
	return result;
}

void quit() {
}


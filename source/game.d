import input;
import entity;
import ai;
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
	weps ~= Weapon("Unarmed", [], 1, false, null);
	Sprite[] s;
	for (int i = 1; i <= 8; i++) 
		s ~= new Sprite("Blaster/000" ~ to!string(i) ~ ".png");
	weps ~= Weapon("Blaster", s, 1, false, new Bullet(0., 0., 0., 0.5, new Sprite("Orb.png")));

	p.e = new Mob(0, 0, 0, 1.8, new Sprite("Tower.png"), null);
	ents ~= p.e;
	
	ents ~= new Mob(5, 0, 0, 1.8, new Sprite("Tower.png"), 
		new Sequence(cast(Routine[]) [
			new WaitForWeapon(), 
			new FindTarget(), 
			new Aim(), 
			new Attack()
		])
	);
	(cast(Mob) ents[$-1]).weapon = weps[1];
	(cast(Mob) ents[$-1]).eyeHeight = 1.7;
	
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
		return cmp(abs(a.x - p.e.x) + abs(a.z - p.e.z), abs(b.x - p.e.x) + abs(b.z - p.e.z)) > 0;
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

double expression(double[][2] terms, double x) {
	double result = 0;
	
	for (int i = 0; i < terms.length; i++) {
		result += terms[i][0] * pow(x, terms[i][1]);
	}
	
	return result;
}

void quit() {
}


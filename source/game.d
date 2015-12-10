import input;
import entity;
import render;
import menu;
import std.math;
import std.conv;

double delta;

struct Player {
	Entity e; // The entity this player is controlling
}

Weapon[] weps;
Entity[] ents;
Player p;

void init() {
	weps ~= Weapon("Unarmed", []);
	Sprite[] s;
	for (int i = 1; i <= 8; i++) 
		s ~= new Sprite("Blaster/000" ~ to!string(i) ~ ".png");
	weps ~= Weapon("Blaster", s);

	p.e = new Entity(0, 0, 0, 1.8, new Sprite("Thrash.png"));
	ents ~= p.e;
	ents ~= new Entity(0, 0, 0, 0.4, new Sprite("Thrash.png"));
	ents ~= new Entity(5, 0, 5, 0.4, new Sprite("Thrash.png"));
	
	p.e.weapon = weps[1];
}

void tick(double delta) {	
	game.delta = delta;

	menu.current.event();
}

void quit() {
}


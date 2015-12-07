import input;
import entity;
import render;
import menu;
import std.math;

double delta;

struct Player {
	Entity e; // The entity this player is controlling
};

Entity[] ents;
Player p;

void init() {
	p.e = new Entity(0, 0, 0, 1.8, new Sprite("Thrash.png"));
	ents ~= p.e;
	ents ~= new Entity(0, 0, 0, 0.4, new Sprite("Thrash.png"));
	ents ~= new Entity(5, 0, 5, 0.4, new Sprite("Thrash.png"));
}

void tick(double delta) {	
	game.delta = delta;

	menu.current.event();
}

void quit() {
}


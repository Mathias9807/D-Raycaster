import main;
import game;
import entity;
import std.math;

// States returned by running a routine
enum {
	SUCCESS, FAILURE, RUNNING
};

class Routine {
	private Routine[] r;

	// Takes the entity the routine is controlling and any routines this should run
	this(Routine[] r) {
		this.r = r;
	}
	
	this() {}

	abstract int run(Entity e);
}

// Runs every routine until one fails
class Sequence : Routine {
	private int i = 0;
	
	this(Routine[] r) { super(r); }
	
	override int run(Entity e) {
		if (i == r.length) {
			i = 0;
			return SUCCESS;
		}
		
		int s = r[i].run(e);
		
		switch (s) {
		case SUCCESS: 
			i++;
			break;
		case FAILURE: 
			i = 0;
			return FAILURE;
		case RUNNING: 
			break;
		
		default: 
			return FAILURE;
		}
		
		if (i == r.length) return SUCCESS;
		else return RUNNING;
	}
}

// Fires the weapon
class Attack : Routine {
	override int run(Entity e) {
		Mob m = cast(Mob) e;
		if (main.getTime() - m.lastFired < m.weapon.firerate) return RUNNING;
		
		m.fire();
		
		return SUCCESS;
	}
}

// Finds a target
class FindTarget : Routine {
	override int run(Entity e) {
		Entity best = null;
		foreach (Entity ee; game.ents) {
			if (cast(Mob) ee) {
				if (ee == e) continue;
				
				if (best is null || abs(best.x - e.x) + abs(best.z - e.z) > abs(ee.x - e.x) + abs(ee.z - e.z)) 
					best = ee;
			}
		}
		
		if (best is null) 
			return FAILURE;
		
		(cast(Mob) e).target = best;
		return SUCCESS;
	}
}

// Waits until weapon can fire
class WaitForWeapon : Routine {
	override int run(Entity e) {
		Mob m = cast(Mob) e;
		if (main.getTime() - m.lastFired < m.weapon.firerate) 
			return RUNNING;
		
		return SUCCESS;
	}
}

// Rotates towards target
class Aim : Routine {
	override int run(Entity e) {
		Mob m = cast(Mob) e;
		double angle = atan2(m.target.z - m.z, m.target.x - m.x) + PI / 2;
		double dRot = angle - m.yRot;
		if (dRot > PI) {
			m.yRot += 2 * PI;
			dRot = angle - m.yRot;
		}
		if (dRot < -PI) {
			m.yRot -= 2 * PI;
			dRot = angle - m.yRot;
		}
		std.stdio.writeln(m.yRot);
		
		if (dRot > 0) {
			m.rotate([0, game.delta > dRot ? dRot : game.delta]);
		}else {
			m.rotate([0, -game.delta < dRot ? dRot : -game.delta]);
		}
		
		if (abs(dRot) < game.delta) 
			return SUCCESS;
		else 
			return RUNNING;
	}
}

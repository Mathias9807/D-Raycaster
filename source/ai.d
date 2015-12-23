import main;
import entity;

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


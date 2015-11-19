import derelict.sdl2.sdl;

enum {
	W, A, S, D, UP, DOWN, LEFT, RIGHT
};

bool isPressed(uint k) {
	bool* s = cast(bool*) SDL_GetKeyboardState(null);
	
	switch (k) {
		case W:	return s[SDL_SCANCODE_W];
		case A:	return s[SDL_SCANCODE_A];
		case S:	return s[SDL_SCANCODE_S];
		case D:	return s[SDL_SCANCODE_D];
		case UP:	return s[SDL_SCANCODE_UP];
		case DOWN:	return s[SDL_SCANCODE_DOWN];
		case LEFT:	return s[SDL_SCANCODE_LEFT];
		case RIGHT:	return s[SDL_SCANCODE_RIGHT];
		default: break;
	}
	
	return false;
}

import derelict.sdl2.sdl;

struct Key {
	bool state;
	int kEnum;
}

enum {
	W, A, S, D, UP, DOWN, LEFT, RIGHT, LAST
}

private Key[] keys = [
	{0, SDL_SCANCODE_W}, 
	{0, SDL_SCANCODE_A}, 
	{0, SDL_SCANCODE_S}, 
	{0, SDL_SCANCODE_D}, 
	{0, SDL_SCANCODE_UP}, 
	{0, SDL_SCANCODE_DOWN}, 
	{0, SDL_SCANCODE_LEFT}, 
	{0, SDL_SCANCODE_RIGHT}, 
];

Key[] oldKeys;

void init() {
	oldKeys ~= keys[0..LAST];
}

bool isPressed(uint k) {
	bool* curKeys = getKeys();
	
	keys[k].state = curKeys[keys[k].kEnum];
	oldKeys[0..LAST] = keys[0..LAST];

	return keys[k].state;
}

bool hasChanged() {
	bool* newKeys = getKeys();
	for (int i = 0; i < LAST; i++) 
		if (newKeys[keys[i].kEnum] != keys[i].state) 
			return true;

	return false;
}

bool* getKeys() {
	return cast(bool*) SDL_GetKeyboardState(null);
}


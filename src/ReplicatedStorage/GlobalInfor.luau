--!strict

--[[
	This is static information that is used through out the game.
]]

local GlobalInfo = {}

GlobalInfo.MAX_PLAYERS = 6 --int

GlobalInfo.CAMERA = {
	DEFAULT_FOV = 80, --int
}

GlobalInfo.COLOR_THEME = { --Color3
	ACCENT = {
		RED = Color3.fromRGB(180, 58, 58),
		GREEN = Color3.fromRGB(58, 180, 58),
		BLUE = Color3.fromRGB(58, 58, 180),
		YELLOW = Color3.fromRGB(180, 180, 58),
		WHITE = Color3.fromRGB(243, 243, 243),
	},

	NEUTRAL = {
		TEXT = {
			PRIMARY = Color3.fromRGB(243, 243, 243),
			SECONDARY = Color3.fromRGB(108, 117, 125),
			INVERTED = Color3.fromRGB(30, 30, 30),
		},
		BACKGROUND = {
			LIGHT = Color3.fromRGB(243, 243, 243),
			VERY_LIGHT = Color3.fromRGB(245, 244, 244),
			DARK = Color3.fromRGB(40, 40, 40),
			VERY_DARK = Color3.fromRGB(0, 0, 0),
		},
	},

	HIGHLIGHT = {
		SOFT_WARNING = Color3.fromRGB(255, 154, 3),
		WARNING = Color3.fromRGB(255, 3, 3),
	},
}

GlobalInfo.INFO_TEXT = {
	CHAR_PER_MIN = 17, --int
	PLAYER_COLORS = { --Color3
		[1] = Color3.fromRGB(194, 53, 43),
		[2] = Color3.fromRGB(70, 136, 28),
		[3] = Color3.fromRGB(46, 57, 156),
		[4] = Color3.fromRGB(106, 44, 126),
		[5] = Color3.fromRGB(179, 170, 57),
		[6] = Color3.fromRGB(45, 180, 169),
		[GlobalInfo.MAX_PLAYERS + 1] = Color3.fromRGB(255, 140, 250), --reserved for loading issues
	},
}

GlobalInfo.MOVEMENT = {
	SPEED = { --character speed
		WALKING = 8, --float
		RUNNING = 16, --float
		CROUCHING = 5, --float
	},
	TRACKING = { --body to camera tracking
		LOOK_LERP_SPEED = 0.2, --float
		TURN_STRENGTH = 70, --float
	},
	STAMINA = { --stamina bar
		MAX_STAMINA = 100, --int
		STAMINA_REGEN = 0.07, --float
		STAMINA_DRAIN = 0.11, --float

		FOV_ZOOM_OUT = 7, --int
		REGEN_PAUSE = 1.5, --float
		FULL_STAMIN_WAIT_TIME = 1.5, --float
		FULL_STAMIN_FADE_TIME = 1, --float
		TIRED_TRANSITION_TIME = 1.5, --float
	},
}

GlobalInfo.FLASHLIGHT = {
	LIGHT_SWITCH_SPEED = 1, -- float - should be greater than 0.7
}

GlobalInfo.SPAWN = {
	SPAWN_TIME = 6, --float
}

GlobalInfo.VIEWER = {
	DISPLAY_DIST = 2, --float, stud
	ROTATE_SPEED = 1.5, --float, deg
}

return GlobalInfo

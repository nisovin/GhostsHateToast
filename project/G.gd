extends Node

const Toast = preload("res://Toast.tscn")
const Crumb = preload("res://Crumb.tscn")
const Ghost = preload("res://Ghost.tscn")
const Powerup = preload("res://Powerup.tscn")
const PowerupMessage = preload("res://PowerupMessage.tscn")

var save_data = {
	"high_score": 0,
	"unlocked_cheatcodes": 0
}

func _ready():
	load_game()

func load_game():
	var file = File.new()
	if file.file_exists("user://save.dat"):
		file.open("user://save.dat", File.READ)
		save_data = file.get_var()
		file.close()

func save_game():
	var file = File.new()
	file.open("user://save.dat", File.WRITE)
	file.store_var(save_data)
	file.close()

const sounds = {
	"hurt1": preload("res://sounds/hurt1.wav"),
	"hurt2": preload("res://sounds/hurt2.wav"),
	"hurt3": preload("res://sounds/hurt3.wav"),
	"hurt4": preload("res://sounds/hurt4.wav"),
	"hurt5": preload("res://sounds/hurt5.wav"),
	"die1": preload("res://sounds/die1.wav"),
	"die2": preload("res://sounds/die2.wav"),
	"die3": preload("res://sounds/die3.wav")
}

const powerup_database = [
	{ "id": "triple", "weight": 5, "name": "Extra Toasters", "duration": 10 },
	{ "id": "rapid_fire", "weight": 10, "name": "Quick Toast", "duration": 15 },
	{ "id": "two_slot", "weight": 10, "name": "Double Slot Toaster", "duration": 15 },
	{ "id": "four_slot", "weight": 3, "name": "Quad Slot Toaster", "duration": 10 }
]

const cheatcode_database = [
	"YEAST",
	"GLUTEN",
	"CROSSOVER"
]

const ghost_database = [
	{ # small ghost
		"sprite": 0,
		"weight": 20,
		"mult": 1,
		"hp": 1,
		"speed": 100,
		"hurt_sounds": [],
		"death_sounds": ["hurt1", "hurt2", "hurt3"]
	},
	{ # big ghost
		"sprite": 1,
		"weight": 5,
		"after": 3,
		"mult": 1.5,
		"hp": 2,
		"speed": 100,
		"hurt_sounds": ["hurt4"],
		"death_sounds": ["die1"]
	},
	{ # small fast ghost
		"sprite": 0,
		"tint": Color.orange,
		"weight": 5,
		"after": 6,
		"cd": 2,
		"mult": 1.5,
		"hp": 1,
		"speed": 160,
		"hurt_sounds": [],
		"death_sounds": ["hurt1", "hurt2", "hurt3"]
	},
	{ # small drop ghost
		"sprite": 0,
		"tint": Color.limegreen,
		"weight": 10,
		"after": 15,
		"cd": 10,
		"mult": 1,
		"hp": 2,
		"speed": 130,
		"drop": 1,
		"hurt_sounds": [],
		"death_sounds": ["hurt1", "hurt2", "hurt3"]
	},
	{ # big fast ghost
		"sprite": 1,
		"tint": Color.orange,
		"weight": 5,
		"after": 10,
		"cd": 5,
		"mult": 2.0,
		"hp": 2,
		"speed": 140,
		"drop": 0.05,
		"hurt_sounds": ["hurt4"],
		"death_sounds": ["die1"]
	},
	{ # big beefy ghost
		"sprite": 1,
		"tint": Color.dodgerblue,
		"weight": 2,
		"after": 10,
		"cd": 5,
		"mult": 2.0,
		"hp": 3,
		"speed": 100,
		"drop": 0.05,
		"hurt_sounds": ["hurt4"],
		"death_sounds": ["die1"]
	},
	{ # boss ghost
		"sprite": 2,
		"weight": 10,
		"after": 15,
		"cd": 15,
		"mult": 3,
		"hp": 6,
		"speed": 75,
		"drop": 1,
		"hurt_sounds": ["hurt5"],
		"death_sounds": ["die3"]
	},
	{ # beefy boss ghost
		"sprite": 2,
		"tint": Color.dodgerblue,
		"weight": 1,
		"after": 30,
		"cd": 30,
		"mult": 6,
		"hp": 15,
		"speed": 50,
		"drop": 1.5,
		"hurt_sounds": ["hurt5"],
		"death_sounds": ["die3"]
	}
]

extends Node

signal api_call_complete

const Toast = preload("res://Toast.tscn")
const Bagel = preload("res://Bagel.tscn")
const Crumb = preload("res://Crumb.tscn")
const Ghost = preload("res://Ghost.tscn")
const Powerup = preload("res://Powerup.tscn")
const PowerupMessage = preload("res://PowerupMessage.tscn")

const SAVE_FILE = "user://ghost_toast.dat"

var api_key
var http: HTTPRequest
var api_result = {}

var save_data = {
	"high_score": 0,
	"unlocked_cheatcodes": 0
}

func _ready():
	api_key = APIKey.get_key()
	load_game()
	http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_http_complete")

func load_game():
	var file = File.new()
	if file.file_exists(SAVE_FILE):
		file.open(SAVE_FILE, File.READ)
		save_data = file.get_var()
		file.close()

func save_game():
	var file = File.new()
	file.open(SAVE_FILE, File.WRITE)
	file.store_var(save_data)
	file.close()

func publish_high_score(player, score):
	var hashed = APIKey.get_hash(player, score)
	http.request("https://nisovin.com/gamejams/save_score.php?key=" + api_key + "&player=" + player + "&score=" + str(score) + "&hash=" + hashed, [], true, HTTPClient.METHOD_GET)
	return self
	
func get_high_scores():
	http.request("https://nisovin.com/gamejams/get_scores.php?key=" + api_key, [], true, HTTPClient.METHOD_GET)
	return self

func _on_http_complete(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var s = body.get_string_from_utf8()
	var r = JSON.parse(s)
	if r.error == OK:
		api_result = r.result
	else:
		api_result = {"error": "JSON error"}
	emit_signal("api_call_complete")

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
	{ "id": "two_slot", "weight": 10, "name": "Double Slot Toaster", "duration": 15 },
	{ "id": "triple", "weight": 3, "name": "Extra Toasters", "duration": 10 },
	{ "id": "rapid_fire", "weight": 8, "name": "Quick Toast", "duration": 15 },
	{ "id": "four_slot", "weight": 2, "name": "Quad Slot Toaster", "duration": 10 },
	{ "id": "splitter", "weight": 5, "name": "Splitter Toast", "duration": 10 },
	{ "id": "dense", "weight": 6, "name": "Bagels (Double Damage)", "duration": 12 }
]

const cheatcode_database = [
	"YEAST", # spawn powerup
	"SANDWICH", # two_slot
	"CREAMCHEESE", # bagels
	"GLUTEN", # side launchers
	"DEATHDOUSPART", # splitter
	"FULLLOAF", # four_slot + rapid_fire
	"THREEOFME", # triple
	"CROSSOVER", # kill all ghosts
	"GRAVEYARD", # spawn lots of ghosts
	"GODOFBREAD", # all powerups
	"PANDEMUERTO", # all powerups, lots of ghosts
]

const ghost_database = [
	{ # small ghost
		"sprite": 0,
		"weight": 20,
		"mult": 1,
		"hp": 8,
		"speed": 100,
		"hurt_sounds": ["hurt1", "hurt2", "hurt3"],
		"death_sounds": ["hurt1", "hurt2", "hurt3"]
	},
	{ # big ghost
		"sprite": 1,
		"weight": 5,
		"after": 3,
		"mult": 1.5,
		"hp": 15,
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
		"hp": 8,
		"speed": 160,
		"hurt_sounds": ["hurt1", "hurt2", "hurt3"],
		"death_sounds": ["hurt1", "hurt2", "hurt3"]
	},
	{ # small drop ghost
		"sprite": 0,
		"tint": Color.blueviolet,
		"weight": 50,
		"after": 15,
		"cd": 15,
		"mult": 1,
		"hp": 15,
		"speed": 120,
		"drop": 1,
		"hurt_sounds": ["hurt1", "hurt2", "hurt3"],
		"death_sounds": ["hurt1", "hurt2", "hurt3"]
	},
	{ # big fast ghost
		"sprite": 1,
		"tint": Color.orange,
		"weight": 5,
		"after": 10,
		"cd": 5,
		"mult": 2.0,
		"hp": 15,
		"speed": 140,
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
		"hp": 30,
		"speed": 100,
		"drop": 0.02,
		"hurt_sounds": ["hurt4"],
		"death_sounds": ["die1"]
	},
	{ # boss ghost
		"sprite": 2,
		"weight": 10,
		"after": 25,
		"cd": 20,
		"mult": 3,
		"hp": 60,
		"speed": 75,
		"drop": 0.75,
		"hurt_sounds": ["hurt5"],
		"death_sounds": ["die3"]
	},
	{ # beefy boss ghost
		"sprite": 2,
		"tint": Color.dodgerblue,
		"weight": 1,
		"after": 40,
		"cd": 30,
		"mult": 6,
		"hp": 120,
		"speed": 50,
		"drop": 1.1,
		"hurt_sounds": ["hurt5"],
		"death_sounds": ["die3"]
	},
	{ # super beefy boss ghost
		"sprite": 2,
		"tint": Color.darkred,
		"weight": 3,
		"after": 150,
		"cd": 75,
		"mult": 20,
		"hp": 200,
		"speed": 25,
		"drop": 2,
		"hurt_sounds": ["hurt5"],
		"death_sounds": ["die3"]
	}
]

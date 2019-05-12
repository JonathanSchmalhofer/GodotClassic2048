extends Node2D

export (int) var value;
export (PackedScene) var next_tile;
onready var effect = get_node("move_tween");
onready var destroy = get_node("destroy_tween");
onready var alpha = get_node("alpha_tween");
onready var timer = get_node("destroy_timer");

func _ready():
	enter_scene();

func enter_scene():
	effect.interpolate_property(self, "scale", Vector2(.3, .3), Vector2(1, 1), .6, Tween.TRANS_CIRC, Tween.EASE_OUT);
	effect.start();

func move(new_position):
	effect.interpolate_property(self, "position", position, new_position, .3, Tween.TRANS_ELASTIC, Tween.EASE_OUT);
	effect.start();

func start_timer():
	destroy_tile();

func destroy_tile():
	# Use a tween to make the tile larger
	destroy.interpolate_property(self, "scale", Vector2(1, 1), Vector2(1.4, 1.4), .6, Tween.TRANS_CUBIC, Tween.EASE_OUT);
	destroy.start();
	# Use a tween to make the tile disappear
	alpha.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .6, Tween.TRANS_SINE, Tween.EASE_OUT);
	alpha.start();

func _on_destroy_timer_timeout():
	destroy_tile();


func _on_alpha_tween_tween_completed(object, key):
	queue_free();


func _on_detsroy_timer_timeout():
	pass # Replace with function body.

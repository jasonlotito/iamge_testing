extends Control

@onready var cont = %VBoxContainer
@onready var texture_rect:TextureRect = %TextureRect
@onready var color_size = %ColorSize
@onready var auto_amount = %AutoAmount
@onready var auto_minus = %AutoMinus
@onready var auto_plus = %AutoPlus
@onready var timer = %Timer
@onready var overlay_color = %OverlayColor
@onready var overlay_amount = %OverlayAmount
@onready var overlay_apply = %OverlayApply

@export var steps = 8:
	set(v):
		if v < 1:
			v = 8
		steps = v
		_build_form()
var starting_vectors : Array[Color] = []
var color_vectors : Array[Color] = []
var mat : ShaderMaterial
const MAX_COLORS : int = 256
const MIN_COLORS : int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().files_dropped.connect(_on_files_dropped)
	mat = texture_rect.material
	
	_build_form()
	
func _cont_remove_children():
	var children = cont.get_children()
	for child in children:
		child.free()

func _build_form():
	starting_vectors.clear()
	color_vectors.clear()
	_cont_remove_children()
	var per_step = 100/steps
	var starting_point = per_step/2
	var vectors:Array[float] = []
	for i in steps:
		var v = starting_point+(per_step * i)
		vectors.append(v)
	
	for i in vectors.size():
		var vector = vectors[i]
		var clr : Color = Color.from_hsv(0, 0, vector/100, 1.0)
		starting_vectors.append(clr)
		color_vectors.append(clr)
		
		var container : HBoxContainer = HBoxContainer.new()
		var picker = ColorPickerButton.new()
		picker.text = "               "
		picker.color = clr
		container.add_child(picker)
		
		var picker2 = ColorPickerButton.new()
		picker2.text = "               "
		picker2.color = clr
		container.add_child(picker2)
		picker2.color_changed.connect(func(color:Color):
			color_vectors[i] = color
		)
		
		var reset_btn = Button.new()
		reset_btn.text = "Reset"
		container.add_child(reset_btn)
		reset_btn.button_down.connect(func():
			color_vectors[i] = clr
			picker2.color = clr
		)
		
		
		cont.add_child(container)
		picker.color_changed.connect(_color_changed)
	print(starting_vectors)
	print(color_vectors)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vec : Array[Vector3] = []
	var clr : Array[Vector3] = []
	for c in starting_vectors.size():
		var color : Color = starting_vectors[c]
		var swap_color : Color = color_vectors[c]
		mat.set_shader_parameter("size", color_size.value)
		vec.append(Vector3(color.r, color.g, color.b))
		clr.append(Vector3(swap_color.r, swap_color.g, swap_color.b))
	
	assert(vec.size() == clr.size(), "colors and swap colors not same size")
	mat.set_shader_parameter("colors", vec)
	mat.set_shader_parameter("swap_colors", clr)
	mat.set_shader_parameter("over_color", overlay_color.color)
	mat.set_shader_parameter("over_amount", overlay_amount.value)
	mat.set_shader_parameter("do_overlay", overlay_apply.button_pressed)
	
func _save_texture():
#	await RenderingServer.frame_post_draw
	$SubViewport.get_texture().get_image().save_png("C:\\Users\\jason\\creenshot.png")

func _color_changed(color:Color):
	pass

func _on_spin_box_value_changed(value):
	steps = value
	
func _on_files_dropped(files:PackedStringArray):
	print(files)
	var image = Image.load_from_file(files[0])
	var texture = ImageTexture.create_from_image(image)
	texture_rect.texture = texture

	

var is_auto_plus = true;

func _on_auto_plus_pressed():
	is_auto_plus = true
	timer.start(1)


func _on_auto_minus_pressed():
	is_auto_plus = false
	timer.start(1)


func _on_timer_timeout():
	if is_auto_plus:
		if color_size.value + auto_amount.value >= MAX_COLORS:
			color_size.value = MAX_COLORS
			timer.stop()
		else:
			color_size.value += auto_amount.value
	else:
		if color_size.value - auto_amount.value <= MIN_COLORS:
			color_size.value = MIN_COLORS
			timer.stop()
		else:
			color_size.value -= auto_amount.value


func _on_auto_stop_pressed():
	timer.stop()

extends CanvasLayer

@onready var label_xp = $Panel_xp/Label_xp

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_atualizar_xp()

func _process(_delta):
	_atualizar_xp()
	
	if Input.is_action_just_pressed("menu"):
		_alternar_menu_pause()

func _atualizar_xp():
	label_xp.text = "XP: %d" % PlayerDados.xp

const CENA_MENU_PAUSE = "res://cenas/interface/menu_pause.scn"
var menu_pause_instancia: Node = null



func _alternar_menu_pause():
	if get_tree().paused:
		_fechar_menu_pause()
	else:
		_abrir_menu_pause()

func _abrir_menu_pause():
	menu_pause_instancia = load(CENA_MENU_PAUSE).instantiate()
	menu_pause_instancia.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_pause_instancia.fechar_solicitado.connect(_fechar_menu_pause)
	get_tree().root.add_child(menu_pause_instancia)
	get_tree().paused = true

func _fechar_menu_pause():
	get_tree().paused = false
	var instancia = menu_pause_instancia
	menu_pause_instancia = null
	if instancia != null and is_instance_valid(instancia):
		instancia.queue_free()

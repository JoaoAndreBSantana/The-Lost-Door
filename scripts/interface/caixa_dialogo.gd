extends CanvasLayer

signal dialogo_encerrado

var dialogos = []
var indice_atual = 0

@onready var portrait = $Panel/TextureRect_icone
@onready var label_nome = $Panel/Label_nome
@onready var label_texto = $Panel/Label_texto

func _ready():
	hide()

func iniciar(nome_npc: String, textos: Array, foto: Texture2D = null, player = null):
	dialogos = textos
	indice_atual = 0
	label_nome.text = nome_npc
	portrait.texture = foto
	portrait.visible = foto != null
	mostrar_linha_atual()
	if player:
		player.em_dialogo = true
	show()

func mostrar_linha_atual():
	label_texto.text = dialogos[indice_atual]

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("interagir"):
		get_viewport().set_input_as_handled()
		avancar()

func avancar():
	indice_atual += 1
	if indice_atual >= dialogos.size():
		encerrar()
	else:
		mostrar_linha_atual()

func encerrar():
	hide()
	emit_signal("dialogo_encerrado")

extends CanvasLayer

@onready var btn_novo_jogo = $VBoxContainer/Button_novo_jogo
@onready var btn_carregar = $VBoxContainer/Button_carregar_jogo
@onready var btn_tutorial = $VBoxContainer/Button_tutorial
@onready var panel_tutorial = $VBoxContainer/Panel_tutorial
@onready var btn_voltar_tutorial = $VBoxContainer/Panel_tutorial/VBoxContainer/Button_voltar_tutorial

const CENA_MAPA = "res://cenas/cena_main.scn"
const CENA_NARRATIVA = "res://cenas/interface/interface_narrativa.scn"


func _ready():
	
	MusicaGlobal.tocar_musica(MusicaGlobal.musica_tela_inicio)
	
	btn_novo_jogo.pressed.connect(_novo_jogo)
	btn_carregar.pressed.connect(_carregar_jogo)
	btn_tutorial.pressed.connect(_abrir_tutorial)
	btn_voltar_tutorial.pressed.connect(_fechar_tutorial)
	if not SaveSistema.existe_save():
		btn_carregar.disabled = true
	btn_novo_jogo.grab_focus()

func _novo_jogo():
	SaveSistema.resetar_dados()
	SaveSistema.narrativa_pendente = load("res://recursos/narrativas/intro.tres")
	get_tree().change_scene_to_file(CENA_NARRATIVA)

func _carregar_jogo():
	if SaveSistema.existe_save():
		SaveSistema.carregar()
		get_tree().change_scene_to_file(CENA_MAPA)
	else:
		btn_carregar.text = "Sem save encontrado!"

func _abrir_tutorial():
	panel_tutorial.visible = true
	btn_voltar_tutorial.grab_focus()

func _fechar_tutorial():
	panel_tutorial.visible = false
	btn_novo_jogo.grab_focus()

extends CharacterBody2D
class_name MobBase

enum TipoMovimento {
	ESTATICO,
	LADO_A_LADO,
	FRENTE_COSTAS,
	DIAGONAL
}

@export var tipo_movimento: TipoMovimento = TipoMovimento.LADO_A_LADO
@export var velocidade = 30.0
@export var tempo_andando = 2.0
@export var tempo_parado = 1.5

#caixa de dialogo
@export var nome_npc = "NPC"
@export var dialogos: Array = []
@export var icone_dialogo: Texture2D = null

# dados de combate
@export var hp_maximo = 30
@export var hp_atual = 30
@export var ataque_base = 5
@export var xp_drop = 10
@export var tipo_mob = "recruta" 
@export var sprite_combate: Texture2D = null
@export var iniciar_combate_apos_dialogo = true

@export var golpes: Array[Golpe] = []


var caixa_dialogo = null

var direcao = 1 
var tempo_acumulado = 0.0
var esta_parado = false
var player_perto = false
var esta_conversando = false 
var player_ref = null 

@onready var anim = $AnimatedSprite2D

func _ready():
	caixa_dialogo = CaixaDialogo.get_node("CanvasLayer")
	
	
func _physics_process(delta):
	if esta_conversando:
		return

	tempo_acumulado += delta

	if esta_parado:
		anim.play("mob_frente_parado")
		if tempo_acumulado >= tempo_parado:
			esta_parado = false
			tempo_acumulado = 0.0
			direcao *= -1
	else:
		match tipo_movimento:
			TipoMovimento.ESTATICO:
				velocity = Vector2.ZERO
				anim.play("mob_frente_parado")
			TipoMovimento.LADO_A_LADO:
				velocity.x = direcao * velocidade
				velocity.y = 0
				anim.play("anima_lado_dir" if direcao == 1 else "anima_lado_esq")
			TipoMovimento.FRENTE_COSTAS:
				velocity.y = direcao * velocidade
				velocity.x = 0
				anim.play("anima_frente" if direcao == 1 else "anima_costa")
			TipoMovimento.DIAGONAL:
				velocity.x = direcao * velocidade
				velocity.y = direcao * velocidade * 0.5
				anim.play("anima_lado_dir" if direcao == 1 else "anima_lado_esq")

		if tempo_acumulado >= tempo_andando:
			esta_parado = true
			tempo_acumulado = 0.0
			velocity = Vector2.ZERO

	global_position += velocity * delta

func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_perto:
		if not esta_conversando:
			olhar_para_player()
			esta_conversando = true
			caixa_dialogo.iniciar(nome_npc, dialogos, icone_dialogo, player_ref)
			caixa_dialogo.dialogo_encerrado.connect(_on_dialogo_encerrado)

func olhar_para_player():
	if player_ref == null: return
	
	var diff = player_ref.global_position - global_position
	
	if abs(diff.x) > abs(diff.y):
		if diff.x > 0:
			anim.play("mob_lado_dir_parado")
		else:
			anim.play("mob_lado_esq_parado")
	else:
		if diff.y > 0:
			anim.play("mob_frente_parado")
		else:
			anim.play("mob_costa_parado")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		player_perto = true
		player_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		player_perto = false
		player_ref = null
		esta_conversando = false

func _on_dialogo_encerrado():
	esta_conversando = false
	caixa_dialogo.dialogo_encerrado.disconnect(_on_dialogo_encerrado)
	
	
	if iniciar_combate_apos_dialogo:
		CombateSistema.iniciar_combate(player_ref, self)
	
	

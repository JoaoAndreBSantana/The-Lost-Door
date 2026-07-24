extends CharacterBody2D

const SPEED = 150.0
@onready var anim = $AnimatedSprite2D


var ultima_direcao = "frente"

var em_dialogo = false


func _ready():
	CaixaDialogo.get_node("CanvasLayer").dialogo_encerrado.connect(_on_dialogo_encerrado)
	
	add_to_group("player")
	
	SaveSistema.player_node = self 
	
	if SaveSistema.tem_posicao_salva: 
		global_position = Vector2(SaveSistema.player_x, SaveSistema.player_y)
		
		
		ultima_direcao = SaveSistema.ultima_direcao 
		anim.play(ultima_direcao)
		
		SaveSistema.tem_posicao_salva = false


func _on_dialogo_encerrado():
	em_dialogo = false

func _physics_process(_delta):
	if em_dialogo:
		velocity = Vector2.ZERO
		move_and_slide()
		anim.play(ultima_direcao)
		return
	var direction = Input.get_vector("esquerda", "direita", "cima", "baixo")
	velocity = direction * SPEED
	move_and_slide()

	if direction != Vector2.ZERO:
		if direction.x > 0:
			ultima_direcao = "direita" 
			anim.play("anima_direita") 
		elif direction.x < 0:
			ultima_direcao = "esquerda"
			anim.play("anima_esquerda")
		elif direction.y > 0:
			ultima_direcao = "frente"
			anim.play("anima_frente")
		elif direction.y < 0:
			ultima_direcao = "costa"
			anim.play("anima_costa")
	else:
		
		anim.play(ultima_direcao)
		

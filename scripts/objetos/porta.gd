extends StaticBody2D

@export var nome_boss_necessario: String = ""

func _ready():
	
	add_to_group("portas_boss")
	
	
	if nome_boss_necessario in PlayerDados.bosses_derrotados:
		queue_free()


func checar_liberacao():
	if nome_boss_necessario in PlayerDados.bosses_derrotados:
		queue_free() 

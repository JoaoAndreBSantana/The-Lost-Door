extends MobBase
class_name BossBase

var is_boss: bool = true

@export var dialogos_apos_derrota: Array = ["..."]

func _ready():
	super._ready()
	add_to_group("bosses")
	tipo_movimento = TipoMovimento.ESTATICO
	iniciar_combate_apos_dialogo = true
	_atualizar_estado()

func _atualizar_estado():
	if nome_npc in PlayerDados.bosses_derrotados:
		iniciar_combate_apos_dialogo = false
		dialogos = dialogos_apos_derrota

func olhar_para_player():
	anim.play("mob_frente_parado")

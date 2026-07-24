extends MobBase
class_name NpcBase

func _ready():
	super._ready()
	iniciar_combate_apos_dialogo = false
	tipo_movimento = TipoMovimento.ESTATICO

func olhar_para_player():
	pass

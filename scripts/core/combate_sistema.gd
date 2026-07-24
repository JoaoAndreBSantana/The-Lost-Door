extends Node

# referências de quem vai lutar
var player_ref = null
var mob_ref = null

var mob_hp = 0
var mob_nome = ""
var mob_tipo = ""
var mob_sprite = null
var mob_golpes = []
var mob_ataque = 0
var mob_xp = 0

# resultado do combate
var resultado = ""  

var combate_instancia: Node = null
const CENA_COMBATE := "res://cenas/interface/combate_interface.scn"

func _salvar_dados_mob(mob):
	mob_hp = mob.hp_maximo
	mob_nome = mob.nome_npc
	mob_tipo = mob.tipo_mob
	mob_sprite = mob.sprite_combate
	mob_golpes = mob.golpes
	mob_ataque = mob.ataque_base
	mob_xp = mob.xp_drop
	
func iniciar_combate(player, mob):
	player_ref = player
	mob_ref = mob
	
	_salvar_dados_mob(mob)
	
	var cena_combate: PackedScene = load(CENA_COMBATE)
	combate_instancia = cena_combate.instantiate()
	combate_instancia.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(combate_instancia)
	get_tree().paused = true
	
	MusicaGlobal.tocar_musica(MusicaGlobal.musica_combate)

func encerrar_combate(res: String):
	resultado = res
	player_ref = null
	mob_ref = null
	get_tree().paused = false
	
	if combate_instancia != null:
		combate_instancia.queue_free()
		combate_instancia = null
		
	MusicaGlobal.tocar_musica(MusicaGlobal.musica_mapa)

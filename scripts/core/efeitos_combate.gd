extends Node

var interface: Node = null

# estados do jogador
var player_veneno_turnos: int = 0
var player_atordoado: bool = false
var player_sangramento: bool = false
var player_turno_roubado: int = 0

# estados do mob
var mob_atordoado: bool = false
var mob_veneno_turnos: int = 0     
var mob_sangramento: bool = false   
var mob_turno_roubado: int = 0      


var foco_ativo: bool = false
var contra_ataque_ativo: bool = false
var mob_refletindo: bool = false


var _tween_inimigo: Tween = null
var _tween_player: Tween = null

func inicializar(interface_ref: Node) -> void:
	interface = interface_ref


func piscar_sprite(sprite: CanvasItem, cor: Color) -> void:
	if sprite == null or interface == null:
		return
	if sprite == interface.sprite_inimigo:
		if _tween_inimigo != null and _tween_inimigo.is_valid():
			_tween_inimigo.kill()
		sprite.modulate = cor
		var tween = interface.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
		_tween_inimigo = tween
	else:
		if _tween_player != null and _tween_player.is_valid():
			_tween_player.kill()
		sprite.modulate = cor
		var tween = interface.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
		_tween_player = tween


func aplicar(golpe: Golpe, eh_player: bool) -> void:
	match golpe.efeito:
		"foco":
			foco_ativo = true
			interface.label_mensagem.text = "Você usou Foco! Próximo ataque dobrado!"
			piscar_sprite(interface.sprite_player, Color(0.4, 0.7, 1.0))

		"atordoar":
			if randf() < 0.5:
				if eh_player:
					mob_atordoado = true
					interface.label_mensagem.text += " Inimigo foi atordoado!"
					piscar_sprite(interface.sprite_inimigo, Color(1.0, 0.85, 0.0))
				else:
					player_atordoado = true
					interface.label_mensagem.text += " Você foi atordoado!"
					piscar_sprite(interface.sprite_player, Color(1.0, 0.85, 0.0))

		"veneno":
			if eh_player: 
				if not interface.mob_defendendo:
					mob_veneno_turnos = 4
					interface.label_mensagem.text += " O inimigo foi envenenado!"
					piscar_sprite(interface.sprite_inimigo, Color(0.3, 0.8, 0.2))
			else: 
				if not interface.defendendo:
					player_veneno_turnos = 4
					interface.label_mensagem.text += " Você foi envenenado!"
					piscar_sprite(interface.sprite_player, Color(0.3, 0.8, 0.2))

		"sangramento":
			if eh_player: 
				if not interface.mob_defendendo:
					mob_sangramento = true
					interface.label_mensagem.text += " O inimigo está sangrando!"
					piscar_sprite(interface.sprite_inimigo, Color(0.8, 0.0, 0.1))
			else: 
				if not interface.defendendo:
					player_sangramento = true
					interface.label_mensagem.text += " Você está sangrando!"
					piscar_sprite(interface.sprite_player, Color(0.8, 0.0, 0.1))

		"turno_roubado":
			
			if randf() < 0.5:
				if eh_player: 
					if not interface.mob_defendendo:
						mob_turno_roubado += 1 
						interface.label_mensagem.text += " O turno do inimigo foi roubado!"
						piscar_sprite(interface.sprite_inimigo, Color(0.5, 0.0, 0.8))
				else: 
					if not interface.defendendo:
						player_turno_roubado += 1 
						interface.label_mensagem.text += " Seu turno foi roubado!"
						piscar_sprite(interface.sprite_player, Color(0.5, 0.0, 0.8))
			

		"refletir":
			if not eh_player: 
				mob_refletindo = true
				interface.label_mensagem.text = "%s entrou em Postura Reativa!" % CombateSistema.mob_nome
				piscar_sprite(interface.sprite_inimigo, Color(0.4, 0.7, 1.0))

		"contra_ataque":
			if eh_player: 
				contra_ataque_ativo = true
				interface.label_mensagem.text = "Você entrou em postura de Contra-Ataque!"
				piscar_sprite(interface.sprite_player, Color(0.4, 0.7, 1.0))


func verificar_turno_player() -> bool:
	if player_turno_roubado > 0:
		player_turno_roubado -= 1
		interface.label_mensagem.text = "Seu turno foi roubado! O inimigo age novamente!"
		piscar_sprite(interface.sprite_player, Color(0.5, 0.0, 0.8))
		return false
	if player_atordoado:
		player_atordoado = false
		interface.label_mensagem.text = "Você está atordoado e perdeu o turno!"
		piscar_sprite(interface.sprite_player, Color(1.0, 0.85, 0.0))
		return false
	return true


func verificar_turno_mob() -> bool:
	if mob_turno_roubado > 0:
		mob_turno_roubado -= 1
		interface.label_mensagem.text = "O turno do inimigo foi roubado! Você age novamente!"
		piscar_sprite(interface.sprite_inimigo, Color(0.5, 0.0, 0.8))
		return false
	if mob_atordoado:
		mob_atordoado = false
		interface.label_mensagem.text = "%s está atordoado e perdeu o turno!" % CombateSistema.mob_nome
		piscar_sprite(interface.sprite_inimigo, Color(1.0, 0.85, 0.0))
		return false
	return true


func aplicar_sangramento(eh_player: bool) -> bool:
	if eh_player:
		if not player_sangramento:
			return false
		player_sangramento = false
		var dano = 8
		PlayerDados.hp_atual = max(PlayerDados.hp_atual - dano, 0)
		interface.label_mensagem.text = "Você sangrou e perdeu %d HP!" % dano
		piscar_sprite(interface.sprite_player, Color(0.8, 0.0, 0.1))
		interface._atualizar_barras()
		return PlayerDados.hp_atual <= 0
	else:
		if not mob_sangramento:
			return false
		mob_sangramento = false
		var dano = 8
		interface.mob_hp = max(interface.mob_hp - dano, 0)
		interface.label_mensagem.text = "%s sangrou e perdeu %d HP!" % [CombateSistema.mob_nome, dano]
		piscar_sprite(interface.sprite_inimigo, Color(0.8, 0.0, 0.1))
		interface._atualizar_barras()
		return interface.mob_hp <= 0


func processar_fim_turno() -> Dictionary:
	var player_vivo = true
	var mob_vivo = true
	var mensagens = []

	# 1. Veneno no Player
	if player_veneno_turnos > 0:
		player_veneno_turnos -= 1
		var dano_p = 5
		PlayerDados.hp_atual = max(PlayerDados.hp_atual - dano_p, 0)
		piscar_sprite(interface.sprite_player, Color(0.3, 0.8, 0.2))
		if player_veneno_turnos > 0:
			mensagens.append("Você sofreu %d de dano de veneno! (%d turnos restantes)" % [dano_p, player_veneno_turnos])
		else:
			mensagens.append("Você sofreu %d de dano de veneno! Efeito acabou." % dano_p)
		if PlayerDados.hp_atual <= 0:
			player_vivo = false

	
	if mob_veneno_turnos > 0:
		mob_veneno_turnos -= 1
		var dano_m = 5
		interface.mob_hp = max(interface.mob_hp - dano_m, 0)
		piscar_sprite(interface.sprite_inimigo, Color(0.3, 0.8, 0.2))
		if mob_veneno_turnos > 0:
			mensagens.append("%s sofreu %d de dano de veneno! (%d turnos restantes)" % [CombateSistema.mob_nome, dano_m, mob_veneno_turnos])
		else:
			mensagens.append("%s sofreu %d de dano de veneno! Efeito acabou." % CombateSistema.mob_nome)
		if interface.mob_hp <= 0:
			mob_vivo = false

	if mensagens.size() > 0:
		interface.label_mensagem.text = " | ".join(mensagens)
		interface._atualizar_barras()

	return {"player_vivo": player_vivo, "mob_vivo": mob_vivo}


func limpar() -> void:
	player_veneno_turnos = 0
	player_atordoado = false
	player_sangramento = false
	player_turno_roubado = 0
	mob_atordoado = false
	mob_veneno_turnos = 0       
	mob_sangramento = false     
	mob_turno_roubado = 0
	foco_ativo = false
	contra_ataque_ativo = false
	mob_refletindo = false

extends CanvasLayer

@onready var conteudo = $Control

# referências dos nós de interface
@onready var sprite_inimigo = $Control/Sprite_inimigo
@onready var sprite_player = $Control/Sprite_player

# painéis de status
@onready var panel_inimigo = $Control/Panel_inimigo
@onready var label_nome_inimigo = $Control/Panel_inimigo/Label_nome
@onready var barra_hp_inimigo = $Control/Panel_inimigo/ProgressBar_hp
@onready var _efeitos = $EfeitosGolpe

@onready var panel_player = $Control/Panel_player
@onready var label_nome_player = $Control/Panel_player/Label_nome
@onready var barra_hp_player = $Control/Panel_player/ProgressBar_hp
@onready var barra_st_player = $Control/Panel_player/ProgressBar_st

# painel de ação
@onready var label_mensagem = $Control/Panel_acao/Label_mensagem
@onready var panel_menu_principal = $Control/Panel_acao/Panel_menu_principal
@onready var panel_menu_lutar = $Control/Panel_acao/Panel_menu_lutar
@onready var panel_itens = $Control/Panel_acao/Panel_itens

# botões do menu principal
@onready var btn_atacar = $Control/Panel_acao/Panel_menu_principal/GridContainer/Button_atacar
@onready var btn_inventario = $Control/Panel_acao/Panel_menu_principal/GridContainer/Button_inventario
@onready var btn_defender = $Control/Panel_acao/Panel_menu_principal/GridContainer/Button_defender
@onready var btn_fugir = $Control/Panel_acao/Panel_menu_principal/GridContainer/Button_fugir

# botões de habilidades
@onready var btns_hab = [
	$Control/Panel_acao/Panel_menu_lutar/VBoxContainer/Button_hab01,
	$Control/Panel_acao/Panel_menu_lutar/VBoxContainer/Button_hab02,
	$Control/Panel_acao/Panel_menu_lutar/VBoxContainer/Button_hab03,
	$Control/Panel_acao/Panel_menu_lutar/VBoxContainer/Button_hab04,
	$Control/Panel_acao/Panel_menu_lutar/VBoxContainer/Button_hab05
]
@onready var btn_voltar_lutar = $Control/Panel_acao/Panel_menu_lutar/VBoxContainer/Button_voltar

# botões de itens
@onready var btn_pocao_hp = $Control/Panel_acao/Panel_itens/VBoxContainer/Button_pocao_hp
@onready var btn_pocao_st = $Control/Panel_acao/Panel_itens/VBoxContainer/Button_pocao_st
@onready var btn_voltar_itens = $Control/Panel_acao/Panel_itens/VBoxContainer/Button_voltar

# estado do combate
var turno_player = true
var defendendo = false
var mob_hp = 0
var mob_hp_max = 0
var mob_ref = null
var player_ref = null


var mob_pocoes_vida = 1
var mob_cooldown = {} 
var mob_defendendo = false

func _conectar_botoes():
	# menu principal
	btn_atacar.pressed.connect(_on_btn_atacar)
	btn_inventario.pressed.connect(_on_btn_inventario)
	btn_defender.pressed.connect(_on_btn_defender)
	btn_fugir.pressed.connect(_on_btn_fugir)
	
	# menu lutar
	btn_voltar_lutar.pressed.connect(_mostrar_menu_principal)
	for i in range(btns_hab.size()):
		var idx = i
		btns_hab[i].pressed.connect(func(): _on_habilidade_escolhida(idx))
	
	# menu itens
	btn_pocao_hp.pressed.connect(_on_usar_pocao_hp)
	btn_pocao_st.pressed.connect(_on_usar_pocao_st)
	btn_voltar_itens.pressed.connect(_mostrar_menu_principal)

func _on_btn_atacar():
	_mostrar_menu_lutar()

func _on_btn_inventario():
	_mostrar_menu_itens()
	_atualizar_itens()

func _on_btn_defender():
	if not turno_player:
		return
	defendendo = true
	label_mensagem.text = "Você assumiu postura defensiva!"
	_bloquear_menu()
	await get_tree().create_timer(1.0).timeout
	_turno_mob()

func _on_btn_fugir():
	if not turno_player:
		return
	label_mensagem.text = "Você fugiu do combate!"
	
	PlayerDados.hp_atual = PlayerDados.hp_maximo
	PlayerDados.stamina_atual = PlayerDados.stamina_maxima
	
	await get_tree().create_timer(1.0).timeout
	CombateSistema.encerrar_combate("fuga")

func _bloquear_menu():
	panel_menu_principal.visible = false
	panel_menu_lutar.visible = false
	panel_itens.visible = false

func _liberar_menu():
	turno_player = true
	defendendo = false


	if not _efeitos.verificar_turno_player():
		turno_player = false
		_bloquear_menu()
		await get_tree().create_timer(1.5).timeout
		_turno_mob()
		return

	_mostrar_menu_principal()
	label_mensagem.text = "O que você vai fazer?"

		
func _ready():
	
	conteudo.modulate.a = 0.0
	
	_efeitos.inicializar(self)
	_conectar_botoes() 
	
	btn_atacar.text = "Lutar"
	btn_inventario.text = "Itens"
	btn_defender.text = "Defender"
	btn_fugir.text = "Fugir"
	btn_voltar_lutar.text = "Voltar"
	btn_voltar_itens.text = "Voltar"
	
	# referências do CombateSistema
	mob_ref = CombateSistema.mob_ref
	player_ref = CombateSistema.player_ref
	
	# dados do mob
	mob_hp = CombateSistema.mob_hp
	mob_hp_max = CombateSistema.mob_hp

	
	# configura interface do inimigo
	sprite_inimigo.texture = CombateSistema.mob_sprite
	label_nome_inimigo.text = CombateSistema.mob_nome
	barra_hp_inimigo.max_value = mob_hp_max
	barra_hp_inimigo.value = mob_hp
	
	
	# configura interface do player
	sprite_player.texture = PlayerDados.sprite_combate
	label_nome_player.text = "Jogador"
	barra_hp_player.max_value = PlayerDados.hp_maximo
	barra_hp_player.value = PlayerDados.hp_atual
	barra_st_player.max_value = PlayerDados.stamina_maxima
	barra_st_player.value = PlayerDados.stamina_atual
	
	# configura habilidades
	_atualizar_habilidades()
	
	# configura itens
	_atualizar_itens()
	
	# mostra menu principal
	_mostrar_menu_principal()
	
	# mensagem inicial
	label_mensagem.text = "O que você vai fazer?"
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(conteudo, "modulate:a", 1.0, 1.5)
	
	
func _mostrar_menu_principal():
	panel_menu_principal.visible = true
	panel_menu_lutar.visible = false
	panel_itens.visible = false
	
	btn_atacar.grab_focus()

func _mostrar_menu_lutar():
	panel_menu_principal.visible = false
	panel_menu_lutar.visible = true
	panel_itens.visible = false
	for btn in btns_hab:
		if btn.visible:
			btn.grab_focus()
			break

func _mostrar_menu_itens():
	panel_menu_principal.visible = false
	panel_menu_lutar.visible = false
	panel_itens.visible = true
	var btns_itens = [btn_pocao_hp, btn_pocao_st, btn_voltar_itens]
	for btn in btns_itens:
		if btn.visible and not btn.disabled:
			btn.grab_focus()
			break
	

func _atualizar_habilidades():
	var golpes = PlayerDados.golpes
	for i in range(5):
		if i < golpes.size():
			btns_hab[i].visible = true
			btns_hab[i].text = golpes[i].nome
		else:
			btns_hab[i].visible = false

func _atualizar_itens():
	btn_pocao_hp.text = "Poção de Vida x" + str(PlayerDados.pocoes_vida)
	btn_pocao_hp.disabled = PlayerDados.pocoes_vida <= 0
	btn_pocao_st.text = "Poção de Stamina x" + str(PlayerDados.pocoes_stamina)
	btn_pocao_st.disabled = PlayerDados.pocoes_stamina <= 0

func _atualizar_barras():
	barra_hp_inimigo.value = mob_hp
	barra_hp_player.value = PlayerDados.hp_atual
	barra_st_player.value = PlayerDados.stamina_atual
	
func _animar_dano(barra: ProgressBar, valor_final: int, duracao: float = 0.7) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(barra, "value", valor_final, duracao)
	await tween.finished
	
func _atualizar_barras_animado() -> void:
	_animar_dano(barra_hp_inimigo, mob_hp)
	_animar_dano(barra_hp_player, PlayerDados.hp_atual)
	await _animar_dano(barra_st_player, PlayerDados.stamina_atual)
	
func executar_golpe(golpe: Golpe, eh_player: bool):
	
	if _efeitos.aplicar_sangramento(eh_player):
		await get_tree().create_timer(1.0).timeout
		if eh_player:
			_derrota()
		else:
			_vitoria()
		return

	if eh_player:
		if PlayerDados.stamina_atual < golpe.custo_stamina:
			label_mensagem.text = "Stamina insuficiente!"
			_liberar_menu()
			return
		PlayerDados.stamina_atual -= golpe.custo_stamina

	var dano = golpe.dano_base

	if eh_player and _efeitos.foco_ativo:
		dano = dano * 2
		_efeitos.foco_ativo = false 

	if eh_player:
		if mob_defendendo:
			dano = int(dano * 0.5)
			mob_defendendo = false
			
		if _efeitos.mob_refletindo:
			_efeitos.mob_refletindo = false
			PlayerDados.hp_atual -= dano
			PlayerDados.hp_atual = max(PlayerDados.hp_atual, 0)
			_efeitos.piscar_sprite(sprite_player, Color.RED)
			label_mensagem.text = "O mob estava em Postura Reativa! O dano voltou para você!"
		else:
			mob_hp -= dano
			_efeitos.piscar_sprite(sprite_inimigo, Color.RED)
			label_mensagem.text = "Você usou %s! Causou %d de dano!" % [golpe.nome, dano]

	else: 
		if defendendo:
			dano = int(dano * 0.5)
			
		if _efeitos.contra_ataque_ativo:
			mob_hp -= dano
			_efeitos.piscar_sprite(sprite_inimigo, Color.RED)
			label_mensagem.text = "%s tentou atacar mas o dano foi refletido!" % CombateSistema.mob_nome
			_efeitos.contra_ataque_ativo = false
		else:
			PlayerDados.hp_atual -= dano
			_efeitos.piscar_sprite(sprite_player, Color.RED)
			label_mensagem.text = "%s usou %s! Causou %d de dano!" % [CombateSistema.mob_nome, golpe.nome, dano]

	if eh_player:
		PlayerDados.hp_atual = min(PlayerDados.hp_atual + golpe.recupera_hp, PlayerDados.hp_maximo)
		PlayerDados.stamina_atual = min(PlayerDados.stamina_atual + golpe.recupera_st, PlayerDados.stamina_maxima)
	else:
		mob_hp = min(mob_hp + golpe.recupera_hp, mob_hp_max)

	_efeitos.aplicar(golpe, eh_player)

	await _atualizar_barras_animado()
	

func _on_habilidade_escolhida(idx: int):
	if not turno_player:
		return
	
	var golpes = PlayerDados.golpes
	if idx >= golpes.size():
		return
	
	var golpe = golpes[idx]
	
	if PlayerDados.stamina_atual < golpe.custo_stamina:
		label_mensagem.text = "Stamina insuficiente para usar %s!" % golpe.nome
		return
	
	turno_player = false
	_bloquear_menu()
	await executar_golpe(golpe, true)
	
	await get_tree().create_timer(0.4).timeout
	
	if mob_hp <= 0:
		_vitoria()
		return
	
	_turno_mob()

func _on_usar_pocao_hp():
	if not turno_player:
		return
	turno_player = false
	_bloquear_menu()
	PlayerDados.pocoes_vida -= 1
	PlayerDados.hp_atual = min(
		PlayerDados.hp_atual + 80,
		PlayerDados.hp_maximo
	)
	label_mensagem.text = "Você usou Poção de Vida!"
	await _atualizar_barras_animado()
	_atualizar_itens()
	await get_tree().create_timer(1.5).timeout
	_turno_mob()

func _on_usar_pocao_st():
	if not turno_player:
		return
	turno_player = false
	_bloquear_menu()
	PlayerDados.pocoes_stamina -= 1
	PlayerDados.stamina_atual = min(
		PlayerDados.stamina_atual + 80,
		PlayerDados.stamina_maxima
	)
	label_mensagem.text = "Você usou Poção de Stamina!"
	await _atualizar_barras_animado()
	_atualizar_itens()
	await get_tree().create_timer(1.5).timeout
	_turno_mob()
	
func _processar_fim_turno():
	
	var resultado_veneno = _efeitos.processar_fim_turno()
	
	
	if not resultado_veneno["mob_vivo"]:
		await get_tree().create_timer(1.5).timeout
		_vitoria()
		return
		
	
	if not resultado_veneno["player_vivo"]:
		await get_tree().create_timer(1.5).timeout
		_derrota()
		return

	
	if _efeitos.player_veneno_turnos > 0 or _efeitos.mob_veneno_turnos > 0:
		await get_tree().create_timer(1.5).timeout

	_liberar_menu()
	
func _turno_mob():
	turno_player = false
	mob_defendendo = false

	if not _efeitos.verificar_turno_mob():
		await get_tree().create_timer(1.5).timeout
		await _processar_fim_turno()
		return

	for golpe in mob_cooldown.keys():
		mob_cooldown[golpe] -= 1
		if mob_cooldown[golpe] <= 0:
			mob_cooldown.erase(golpe)

	var escolha = _ia_escolher_acao()

	await get_tree().create_timer(1.0).timeout

	match escolha["chave"]:
		"pocao_vida":
			mob_pocoes_vida -= 1
			mob_hp = min(mob_hp + 30, mob_hp_max)
			label_mensagem.text = "%s usou Poção de Vida!" % CombateSistema.mob_nome
			await _atualizar_barras_animado()
		"defender":
			mob_defendendo = true
			label_mensagem.text = "%s assumiu postura defensiva!" % CombateSistema.mob_nome
		_:
			var golpe = escolha["golpe"]
			if golpe == null:
				golpe = CombateSistema.mob_golpes[randi() % CombateSistema.mob_golpes.size()]
			elif golpe.efeito != "":
				mob_cooldown[golpe.efeito] = 2
			await executar_golpe(golpe, false)

	await get_tree().create_timer(2.0).timeout

	if PlayerDados.hp_atual <= 0:
		_derrota()
		return

	await _processar_fim_turno()

	
func _ia_escolher_acao() -> Dictionary:
	var opcoes = []
	opcoes.append({"chave": "ataque_basico", "peso": 10.0, "golpe": null})

	if mob_hp < mob_hp_max * 0.3 and mob_pocoes_vida > 0:
	
		if randf() < 0.5:
			opcoes.append({"chave": "pocao_vida", "peso": 100.0, "golpe": null})

	if not mob_defendendo and randf() < 0.2:
		opcoes.append({"chave": "defender", "peso": 20.0, "golpe": null})

	for golpe in CombateSistema.mob_golpes:
		var peso_golpe = _avaliar_golpe(golpe)
		if peso_golpe > 0:
			peso_golpe += randf_range(0.0, 5.0)
			opcoes.append({"chave": golpe.efeito, "peso": peso_golpe, "golpe": golpe})

	var melhor_acao = opcoes[0]
	for opcao in opcoes:
		if opcao["peso"] > melhor_acao["peso"]:
			melhor_acao = opcao

	return melhor_acao
	
func _avaliar_golpe(golpe: Golpe) -> float:
	
	if mob_cooldown.has(golpe.efeito):
		return 0.0
		
	if golpe.inutil_se_efeito_ativo != "" and golpe.inutil_se_efeito_ativo == "veneno" and _efeitos.player_veneno_turnos > 0:
		return 0.0
	if golpe.inutil_se_efeito_ativo != "" and golpe.inutil_se_efeito_ativo == "atordoar" and _efeitos.player_atordoado:
		return 0.0

	var peso = golpe.prioridade_base

	
	match golpe.categoria:
		"cura":
			
			if (float(mob_hp) / mob_hp_max) > golpe.so_usar_se_hp_abaixo:
				return 0.0
			
			peso += (1.0 - (float(mob_hp) / mob_hp_max)) * 50
			
		"ataque":
			
			if (float(PlayerDados.hp_atual) / PlayerDados.hp_maximo) < 0.3:
				peso += golpe.dano_base * 0.5
				
		"debuff":
			
			peso += 15

	return float(peso)
	
const CENA_NARRATIVA = "res://cenas/interface/interface_narrativa.scn"
	
func _vitoria():
	_bloquear_menu()
	label_mensagem.text = "Você venceu! Recebeu %d XP!" % CombateSistema.mob_xp
	PlayerDados.ganhar_xp(CombateSistema.mob_xp)
	
	if CombateSistema.mob_ref != null and CombateSistema.mob_ref.get("is_boss") == true:
		PlayerDados.derrotar_boss(CombateSistema.mob_nome)
		SaveSistema.salvar()
		get_tree().call_group("portas_boss", "checar_liberacao")
		get_tree().call_group("bosses", "_atualizar_estado")
		
		if CombateSistema.mob_nome == "Senhora dos Sonhos":
			SaveSistema.narrativa_pendente = load("res://recursos/narrativas/fim_jogo.tres")
			get_tree().change_scene_to_file(CENA_NARRATIVA)
		
		#if PlayerDados.bosses_derrotados.size() >= 3:
			#SaveSistema.narrativa_pendente = load("res://recursos/narrativas/fim_jogo.tres")
		
	PlayerDados.hp_atual = PlayerDados.hp_maximo
	PlayerDados.stamina_atual = PlayerDados.stamina_maxima
	
	await get_tree().create_timer(2.0).timeout
	_efeitos.limpar()
	CombateSistema.encerrar_combate("vitoria")

func _derrota():
	_bloquear_menu()
	label_mensagem.text = "Você foi derrotado..."
	PlayerDados.perder_xp(10)
	
	PlayerDados.hp_atual = PlayerDados.hp_maximo
	PlayerDados.stamina_atual = PlayerDados.stamina_maxima
	
	await get_tree().create_timer(2.0).timeout
	_efeitos.limpar()
	CombateSistema.encerrar_combate("derrota")
	

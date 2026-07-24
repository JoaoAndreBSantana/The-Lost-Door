extends CanvasLayer

signal fechar_solicitado

@onready var panel_principal = $Panel_principal
@onready var panel_loja = $Panel_loja
@onready var panel_golpes = $Panel_golpes
@onready var panel_tutorial = $Panel_tutorial

@onready var label_xp = $Panel_principal/VBoxContainer/Label_xp
@onready var label_xp_loja = $Panel_loja/VBoxContainer/Label_xp_loja

@onready var btn_loja = $Panel_principal/VBoxContainer/Button_loja
@onready var btn_golpes = $Panel_principal/VBoxContainer/Button_golpes
@onready var btn_tutorial = $Panel_principal/VBoxContainer/Button_tutorial
@onready var btn_salvar = $Panel_principal/VBoxContainer/Button_salvar
@onready var btn_fechar = $Panel_principal/VBoxContainer/Button_fechar
@onready var btn_sair = $Panel_principal/VBoxContainer/Button_sair

@onready var btn_comprar_pocao_hp = $Panel_loja/VBoxContainer/HBoxContainer/Button_comprar_pocao_hp
@onready var btn_comprar_pocao_st = $Panel_loja/VBoxContainer/HBoxContainer2/Button_comprar_pocao_st
@onready var btn_upar_vida = $Panel_loja/VBoxContainer/HBoxContainer3/Button_upar_vida
@onready var lista_golpes_loja = $Panel_loja/VBoxContainer/ScrollContainer/VBoxContainer_lista
@onready var btn_voltar_loja = $Panel_loja/VBoxContainer/Button_voltar_loja

@onready var lista_meus_golpes = $Panel_golpes/VBoxContainer/ScrollContainer/VBoxContainer_meus_golpes
@onready var btn_voltar_golpes = $Panel_golpes/VBoxContainer/Button_voltar_golpes

@onready var btn_voltar_tutorial = $Panel_tutorial/VBoxContainer/Button_voltar_tutorial

func _ready():
	btn_loja.pressed.connect(_mostrar_loja)
	btn_golpes.pressed.connect(_mostrar_golpes)
	btn_tutorial.pressed.connect(_mostrar_tutorial)
	btn_salvar.pressed.connect(_salvar_jogo)
	btn_fechar.pressed.connect(_fechar_menu)
	btn_sair.pressed.connect(_sair_do_jogo)

	btn_comprar_pocao_hp.pressed.connect(_comprar_pocao_hp)
	btn_comprar_pocao_st.pressed.connect(_comprar_pocao_st)
	btn_upar_vida.pressed.connect(_comprar_vida_upgrade)
	btn_voltar_loja.pressed.connect(_mostrar_principal)

	btn_voltar_golpes.pressed.connect(_mostrar_principal)
	btn_voltar_tutorial.pressed.connect(_mostrar_principal)


	_mostrar_principal()

func _mostrar_principal():
	panel_principal.visible = true
	panel_loja.visible = false
	panel_golpes.visible = false
	panel_tutorial.visible = false
	_atualizar_tudo()
	btn_loja.grab_focus()

func _mostrar_loja():
	panel_principal.visible = false
	panel_loja.visible = true
	_atualizar_loja()
	btn_comprar_pocao_hp.grab_focus()

func _mostrar_golpes():
	panel_principal.visible = false
	panel_golpes.visible = true
	_atualizar_lista_golpes()
	btn_voltar_golpes.grab_focus()

func _mostrar_tutorial():
	panel_principal.visible = false
	panel_tutorial.visible = true
	btn_voltar_tutorial.grab_focus()

func _salvar_jogo():
	SaveSistema.salvar()
	
	
	var texto_original = btn_salvar.text
	btn_salvar.text = "SALVANDO O JOGO"
	btn_salvar.disabled = true 
	
	
	await get_tree().create_timer(1.5).timeout
	btn_salvar.text = texto_original
	btn_salvar.disabled = false

func _fechar_menu():
	fechar_solicitado.emit()

func _sair_do_jogo():
	get_tree().quit()

func _atualizar_tudo():
	label_xp.text = "XP: %d" % PlayerDados.xp

func _atualizar_loja():
	label_xp_loja.text = "XP: %d" % PlayerDados.xp
	
	if PlayerDados.vida_upgrades < PlayerDados.LIMITE_VIDA_UPGRADES:
		var custo_proximo = PlayerDados.CUSTO_VIDA_UPGRADE[PlayerDados.vida_upgrades]
		btn_upar_vida.text = "Upar Vida (%d/%d) - %d XP" % [PlayerDados.vida_upgrades, PlayerDados.LIMITE_VIDA_UPGRADES, custo_proximo]
	else:
		btn_upar_vida.text = "Vida no Máximo!"
	btn_upar_vida.disabled = PlayerDados.vida_upgrades >= PlayerDados.LIMITE_VIDA_UPGRADES
	
	btn_comprar_pocao_hp.text = "Poção de Vida (%d/%d) - %d XP" % [PlayerDados.pocoes_vida, PlayerDados.LIMITE_POCOES, PlayerDados.CUSTO_POCAO_VIDA]
	btn_comprar_pocao_hp.disabled = PlayerDados.pocoes_vida >= PlayerDados.LIMITE_POCOES or PlayerDados.xp < PlayerDados.CUSTO_POCAO_VIDA

	btn_comprar_pocao_st.text = "Poção de Stamina (%d/%d) - %d XP" % [PlayerDados.pocoes_stamina, PlayerDados.LIMITE_POCOES, PlayerDados.CUSTO_POCAO_STAMINA]
	btn_comprar_pocao_st.disabled = PlayerDados.pocoes_stamina >= PlayerDados.LIMITE_POCOES or PlayerDados.xp < PlayerDados.CUSTO_POCAO_STAMINA
	_atualizar_lista_golpes_loja()

func _comprar_pocao_hp():
	PlayerDados.comprar_pocao_vida()
	_atualizar_loja()

func _comprar_pocao_st():
	PlayerDados.comprar_pocao_stamina()
	_atualizar_loja()

func _comprar_vida_upgrade():
	PlayerDados.comprar_vida_upgrade()
	_atualizar_loja()

func _atualizar_lista_golpes_loja():
	for filho in lista_golpes_loja.get_children():
		filho.queue_free()
	for golpe in PlayerDados.golpes_disponiveis_loja:
		if golpe in PlayerDados.golpes_desbloqueados:
			continue
		var botao = Button.new()
		botao.text = "%s\n%s — Comprar (%d XP)" % [golpe.nome, golpe.descricao, golpe.custo_xp]
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botao.custom_minimum_size = Vector2(0, 65)
		botao.disabled = PlayerDados.xp < golpe.custo_xp
		botao.pressed.connect(func(): _comprar_golpe(golpe))
		lista_golpes_loja.add_child(botao)

func _comprar_golpe(golpe: Golpe):
	PlayerDados.comprar_golpe(golpe)
	_atualizar_loja()

func _atualizar_lista_golpes():
	for filho in lista_meus_golpes.get_children():
		filho.queue_free()
	for golpe in PlayerDados.golpes_desbloqueados:
		var equipado = golpe in PlayerDados.golpes
		var botao = Button.new()
		botao.text = "%s\n%s — %s" % [golpe.nome, golpe.descricao, "Equipado ✓" if equipado else "Equipar"]
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botao.custom_minimum_size = Vector2(0, 65)
		botao.pressed.connect(func(): _alternar_golpe(golpe))
		lista_meus_golpes.add_child(botao)

func _alternar_golpe(golpe: Golpe):
	PlayerDados.alternar_equipar_golpe(golpe)
	_atualizar_lista_golpes()

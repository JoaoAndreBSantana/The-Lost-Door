extends Control

@onready var texture_rect = $TextureRect

func _ready():
	var dados = SaveSistema.narrativa_pendente
	SaveSistema.narrativa_pendente = null
	
	if dados == null:
		return
	
	texture_rect.texture = dados.imagem_fundo
	
	var caixa = CaixaDialogo.get_node("CanvasLayer")
	caixa.dialogo_encerrado.connect(_ao_terminar_tudo.bind(dados.proxima_cena))
	caixa.iniciar(dados.nome_exibicao, dados.textos, null)

func _ao_terminar_tudo(proxima_cena: String):
	get_tree().change_scene_to_file(proxima_cena)

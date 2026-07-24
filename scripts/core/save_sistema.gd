extends Node

const CAMINHO_SAVE = "user://save.json"
var player_x: float = 0.0
var player_y: float = 0.0
var ultima_direcao: String = "frente"
var tem_posicao_salva: bool = false
var player_node: Node2D = null
var narrativa_pendente: RecursoNarrativa = null


func salvar() -> void:
	var golpes_desbloqueados_paths = []
	for golpe in PlayerDados.golpes_desbloqueados:
		golpes_desbloqueados_paths.append(golpe.resource_path)
	
	var golpes_equipados_paths = []
	for golpe in PlayerDados.golpes:
		golpes_equipados_paths.append(golpe.resource_path)
	
	if is_instance_valid(player_node): 
		player_x = player_node.global_position.x
		player_y = player_node.global_position.y
		ultima_direcao = player_node.ultima_direcao
		tem_posicao_salva = true
		
	var dados = {
		"xp": PlayerDados.xp,
		"vida_upgrades": PlayerDados.vida_upgrades,
		"hp_atual": PlayerDados.hp_atual,
		"hp_maximo": PlayerDados.hp_maximo,
		"stamina_atual": PlayerDados.stamina_atual,
		"stamina_maxima": PlayerDados.stamina_maxima,
		"pocoes_vida": PlayerDados.pocoes_vida,
		"pocoes_stamina": PlayerDados.pocoes_stamina,
		"golpes_desbloqueados": golpes_desbloqueados_paths,
		"golpes_equipados": golpes_equipados_paths,
		"player_x": player_x,
		"player_y": player_y,
		"ultima_direcao": ultima_direcao,
		"bosses_derrotados": PlayerDados.bosses_derrotados
	}
	
		
	var arquivo = FileAccess.open(CAMINHO_SAVE, FileAccess.WRITE)
	arquivo.store_string(JSON.stringify(dados))
	arquivo.close()

func carregar() -> void:
	if not existe_save():
		return
	
	var arquivo = FileAccess.open(CAMINHO_SAVE, FileAccess.READ)
	var texto = arquivo.get_as_text()
	arquivo.close()
	
	var dados = JSON.parse_string(texto)
	if dados == null:
		return
	
	PlayerDados.xp = dados["xp"]
	PlayerDados.vida_upgrades = dados["vida_upgrades"]
	PlayerDados.hp_atual = dados["hp_atual"]
	PlayerDados.hp_maximo = dados["hp_maximo"]
	PlayerDados.stamina_atual = dados["stamina_atual"]
	PlayerDados.stamina_maxima = dados["stamina_maxima"]
	PlayerDados.pocoes_vida = dados["pocoes_vida"]
	PlayerDados.pocoes_stamina = dados["pocoes_stamina"]
	
	PlayerDados.golpes_desbloqueados.clear()
	for path in dados["golpes_desbloqueados"]:
		PlayerDados.golpes_desbloqueados.append(load(path))
	
	PlayerDados.golpes.clear()
	for path in dados["golpes_equipados"]:
		PlayerDados.golpes.append(load(path))
		
	PlayerDados.bosses_derrotados = dados.get("bosses_derrotados", [])
		
	if dados.has("player_x"):
		player_x = dados["player_x"]
		player_y = dados["player_y"]
		tem_posicao_salva = true
		ultima_direcao = dados.get("ultima_direcao", "frente")
	else:
		tem_posicao_salva = false

func existe_save() -> bool:
	return FileAccess.file_exists(CAMINHO_SAVE)

func resetar_dados() -> void:
	PlayerDados.xp = 0
	PlayerDados.vida_upgrades = 0
	PlayerDados.hp_maximo = PlayerDados.HP_BASE
	PlayerDados.hp_atual = PlayerDados.HP_BASE
	PlayerDados.stamina_maxima = 50
	PlayerDados.stamina_atual = 50
	PlayerDados.pocoes_vida = 0
	PlayerDados.pocoes_stamina = 0
	PlayerDados.golpes_desbloqueados.clear()
	PlayerDados.golpes.clear()
	var golpe_inicial = load("res://recursos/golpes_player/investida.tres")
	PlayerDados.golpes_desbloqueados.append(golpe_inicial)
	PlayerDados.golpes.append(golpe_inicial)
	tem_posicao_salva = false
	player_node = null
	PlayerDados.bosses_derrotados.clear()

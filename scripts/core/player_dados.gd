extends Node

const HP_BASE = 100
const HP_POR_UPGRADE = 20
const LIMITE_VIDA_UPGRADES = 5

var vida_upgrades: int = 0
var hp_maximo = HP_BASE
var hp_atual = 100
var stamina_maxima = 50
var stamina_atual = 50

var xp: int = 0
var pocoes_vida = 0
var pocoes_stamina = 0
const LIMITE_POCOES = 3
const CUSTO_POCAO_VIDA = 15
const CUSTO_POCAO_STAMINA = 15
const CUSTO_VIDA_UPGRADE =  [10, 50, 100, 200, 300]


var sprite_combate: Texture2D = load("res://sprites/player/player_combate.png")

var golpes_desbloqueados: Array = []

var golpes: Array = []


var golpes_disponiveis_loja: Array = [
	load("res://recursos/golpes_player/foco.tres"),
	load("res://recursos/golpes_player/contra_ataque.tres"),
	load("res://recursos/golpes_player/super_golpe.tres"),
	load("res://recursos/golpes_mob/inimigo_01/chute_sonolento.tres"),
	load("res://recursos/golpes_mob/inimigo_01/impacto_pesado.tres"),
	load("res://recursos/golpes_mob/inimigo_01/osso_perfurante.tres"),
	load("res://recursos/golpes_mob/inimigo_02/cuspe_acido.tres"),
	load("res://recursos/golpes_mob/inimigo_02/mordida.tres"),
	load("res://recursos/golpes_mob/inimigo_02/nevoa_toxica.tres"),
	load("res://recursos/golpes_mob/inimigo_02/presa_toxica.tres"),
	load("res://recursos/golpes_mob/inimigo_03/choque_potente.tres"),
	load("res://recursos/golpes_mob/inimigo_03/pulso_eletrico.tres"),
	load("res://recursos/golpes_mob/inimigo_03/super_punch.tres"),
]

func _ready():
	var golpe_inicial = load("res://recursos/golpes_player/investida.tres")
	golpes_desbloqueados.append(golpe_inicial)
	golpes.append(golpe_inicial)


func ganhar_xp(quantidade: int) -> void:
	xp += quantidade
	xp = max(xp, 0)

func perder_xp(quantidade: int) -> void:
	xp -= quantidade
	xp = max(xp, 0)

func upar_vida() -> bool:
	if vida_upgrades >= LIMITE_VIDA_UPGRADES:
		return false
	vida_upgrades += 1
	hp_maximo = HP_BASE + (vida_upgrades * HP_POR_UPGRADE)
	hp_atual = hp_maximo
	return true

func desbloquear_golpe(golpe: Golpe) -> bool:
	if golpe in golpes_desbloqueados:
		return false
	golpes_desbloqueados.append(golpe)
	return true

const LIMITE_GOLPES_EQUIPADOS = 5

func alternar_equipar_golpe(golpe: Golpe) -> void:
	if golpe in golpes:
		golpes.erase(golpe)
	elif golpes.size() < LIMITE_GOLPES_EQUIPADOS:
		golpes.append(golpe)
		
		
func comprar_pocao_vida() -> bool:
	if xp < CUSTO_POCAO_VIDA or pocoes_vida >= LIMITE_POCOES:
		return false
	xp -= CUSTO_POCAO_VIDA
	pocoes_vida += 1
	return true

func comprar_pocao_stamina() -> bool:
	if xp < CUSTO_POCAO_STAMINA or pocoes_stamina >= LIMITE_POCOES:
		return false
	xp -= CUSTO_POCAO_STAMINA
	pocoes_stamina += 1
	return true

func comprar_vida_upgrade() -> bool:
	if vida_upgrades >= LIMITE_VIDA_UPGRADES:
		return false
	var custo = CUSTO_VIDA_UPGRADE[vida_upgrades]
	if xp < custo:
		return false
	upar_vida()
	xp -= custo
	return true

func comprar_golpe(golpe: Golpe) -> bool:
	if xp < golpe.custo_xp:
		return false
	if not desbloquear_golpe(golpe):
		return false
	xp -= golpe.custo_xp
	return true
	
var bosses_derrotados: Array = []  

func derrotar_boss(nome_boss: String) -> void:
	if nome_boss not in bosses_derrotados:
		bosses_derrotados.append(nome_boss)

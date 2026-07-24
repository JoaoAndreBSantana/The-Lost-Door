extends Resource
class_name Golpe

@export var nome = ""
@export var custo_stamina = 0
@export var dano_base = 0
@export var recupera_hp = 0
@export var recupera_st = 0
@export var efeito = ""  
@export var descricao = ""
@export var custo_xp: int = 25


@export var categoria = "ataque"      
@export var prioridade_base = 10        
@export var so_usar_se_hp_abaixo = 1.0  
@export var inutil_se_efeito_ativo = "" 

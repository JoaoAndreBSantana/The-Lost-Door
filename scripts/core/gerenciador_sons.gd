extends Node

@onready var trilha_sonora = $TrilhaSonora


@export var musica_tela_inicio: AudioStream
@export var musica_mapa: AudioStream
@export var musica_combate: AudioStream

func tocar_musica(nova_musica: AudioStream):
	
	if trilha_sonora.stream == nova_musica:
		return
		
	trilha_sonora.stream = nova_musica
	trilha_sonora.play()

func parar_musica():
	trilha_sonora.stop()

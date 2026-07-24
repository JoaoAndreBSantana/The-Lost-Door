extends Resource
class_name RecursoNarrativa

@export var imagem_fundo: Texture2D
@export var nome_exibicao: String = "Narrador"
@export var textos: Array[String]
@export_file("*.scn") var proxima_cena: String

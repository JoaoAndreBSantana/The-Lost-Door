
extends GdUnitTestSuite

const PortaScript := preload("res://scripts/objetos/porta.gd")


func before_test() -> void:
	PlayerDados.bosses_derrotados.clear()


func test_porta_libera_apos_boss_derrotado() -> void:
	var porta = PortaScript.new()
	porta.nome_boss_necessario = "Chefe Teste"

	porta.checar_liberacao()
	assert_bool(porta.is_queued_for_deletion()).is_false()

	PlayerDados.bosses_derrotados.append("Chefe Teste")
	porta.checar_liberacao()
	assert_bool(porta.is_queued_for_deletion()).is_true()

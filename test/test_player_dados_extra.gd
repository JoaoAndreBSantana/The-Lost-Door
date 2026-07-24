
extends GdUnitTestSuite

func before_test() -> void:
	SaveSistema.resetar_dados()


func test_derrotar_boss_nao_duplica() -> void:
	PlayerDados.derrotar_boss("Chefe X")
	PlayerDados.derrotar_boss("Chefe X")  

	var ocorrencias := 0
	for nome in PlayerDados.bosses_derrotados:
		if nome == "Chefe X":
			ocorrencias += 1

	assert_int(ocorrencias).is_equal(1)


func test_comprar_vida_upgrade_respeita_custo_progressivo() -> void:
	
	PlayerDados.xp = 9
	assert_bool(PlayerDados.comprar_vida_upgrade()).is_false()
	assert_int(PlayerDados.vida_upgrades).is_equal(0)

	PlayerDados.xp = 10
	assert_bool(PlayerDados.comprar_vida_upgrade()).is_true()
	assert_int(PlayerDados.vida_upgrades).is_equal(1)
	assert_int(PlayerDados.xp).is_equal(0)

	
	PlayerDados.xp = 49
	assert_bool(PlayerDados.comprar_vida_upgrade()).is_false()

	PlayerDados.xp = 50
	assert_bool(PlayerDados.comprar_vida_upgrade()).is_true()
	assert_int(PlayerDados.vida_upgrades).is_equal(2)

func test_alternar_equipar_golpe_desequipa_ao_chamar_duas_vezes() -> void:
	assert_int(PlayerDados.golpes.size()).is_equal(1)  

	var golpe = PlayerDados.golpes_disponiveis_loja[0]
	PlayerDados.desbloquear_golpe(golpe)

	PlayerDados.alternar_equipar_golpe(golpe)  
	assert_int(PlayerDados.golpes.size()).is_equal(2)
	assert_bool(golpe in PlayerDados.golpes).is_true()

	PlayerDados.alternar_equipar_golpe(golpe)  
	assert_int(PlayerDados.golpes.size()).is_equal(1)
	assert_bool(golpe in PlayerDados.golpes).is_false()

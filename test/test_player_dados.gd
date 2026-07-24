
extends GdUnitTestSuite

func before_test() -> void:
	SaveSistema.resetar_dados()


func test_ganhar_xp_incrementa() -> void:
	PlayerDados.xp = 0
	PlayerDados.ganhar_xp(10)
	assert_int(PlayerDados.xp).is_equal(10)


func test_perder_xp_nao_fica_negativo() -> void:
	PlayerDados.xp = 5
	PlayerDados.perder_xp(10)
	
	assert_int(PlayerDados.xp).is_equal(0)


func test_upar_vida_aumenta_hp_maximo_e_respeita_limite() -> void:
	var sucessos := 0
	
	for i in range(6):
		if PlayerDados.upar_vida():
			sucessos += 1

	assert_int(sucessos).is_equal(PlayerDados.LIMITE_VIDA_UPGRADES)
	assert_int(PlayerDados.vida_upgrades).is_equal(5)
	
	assert_int(PlayerDados.hp_maximo).is_equal(200)
	
	assert_int(PlayerDados.hp_atual).is_equal(PlayerDados.hp_maximo)


func test_comprar_pocao_vida_respeita_limite_e_custo() -> void:
	PlayerDados.xp = 100

	assert_bool(PlayerDados.comprar_pocao_vida()).is_true()
	assert_bool(PlayerDados.comprar_pocao_vida()).is_true()
	assert_bool(PlayerDados.comprar_pocao_vida()).is_true()
	
	assert_int(PlayerDados.pocoes_vida).is_equal(3)
	assert_int(PlayerDados.xp).is_equal(55)

	
	var xp_antes := PlayerDados.xp
	assert_bool(PlayerDados.comprar_pocao_vida()).is_false()
	assert_int(PlayerDados.pocoes_vida).is_equal(3)
	assert_int(PlayerDados.xp).is_equal(xp_antes)  


func test_alternar_equipar_golpe_respeita_limite_de_cinco() -> void:
	
	assert_int(PlayerDados.golpes.size()).is_equal(1)


	var total_na_loja: int = PlayerDados.golpes_disponiveis_loja.size()
	var quantidade_a_testar: int = min(5, total_na_loja)

	for i in range(quantidade_a_testar):
		var golpe = PlayerDados.golpes_disponiveis_loja[i]
		PlayerDados.desbloquear_golpe(golpe)
		PlayerDados.alternar_equipar_golpe(golpe)

	
	assert_int(PlayerDados.golpes.size()).is_less_equal(PlayerDados.LIMITE_GOLPES_EQUIPADOS)


func test_comprar_golpe_desconta_xp_e_desbloqueia() -> void:
	assert_int(PlayerDados.golpes_disponiveis_loja.size()).is_greater(0)

	var golpe = PlayerDados.golpes_disponiveis_loja[0]
	PlayerDados.xp = golpe.custo_xp + 10

	var resultado := PlayerDados.comprar_golpe(golpe)

	assert_bool(resultado).is_true()
	assert_int(PlayerDados.xp).is_equal(10)
	assert_bool(golpe in PlayerDados.golpes_desbloqueados).is_true()

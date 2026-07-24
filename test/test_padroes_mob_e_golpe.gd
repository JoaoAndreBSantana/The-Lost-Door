extends GdUnitTestSuite


func test_mob_base_valores_padrao() -> void:
	var mob := MobBase.new()

	assert_int(mob.tipo_movimento).is_equal(MobBase.TipoMovimento.LADO_A_LADO)
	assert_int(mob.hp_maximo).is_equal(30)
	assert_int(mob.hp_atual).is_equal(30)
	assert_int(mob.ataque_base).is_equal(5)
	assert_str(mob.tipo_mob).is_equal("recruta")
	assert_bool(mob.iniciar_combate_apos_dialogo).is_true()

	mob.free()


func test_golpe_valores_padrao_do_resource() -> void:
	var golpe := Golpe.new()

	assert_str(golpe.categoria).is_equal("ataque")
	assert_int(golpe.prioridade_base).is_equal(10)
	assert_int(golpe.custo_xp).is_equal(25)
	assert_float(golpe.so_usar_se_hp_abaixo).is_equal_approx(1.0, 0.001)


func test_todos_golpes_da_loja_carregam_sem_erro() -> void:
	assert_int(PlayerDados.golpes_disponiveis_loja.size()).is_greater(0)

	for golpe in PlayerDados.golpes_disponiveis_loja:
		assert_object(golpe).is_not_null()
		assert_bool(golpe is Golpe).is_true()
		assert_str(golpe.nome).is_not_empty()

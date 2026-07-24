extends GdUnitTestSuite

func test_golpe_armazena_campos_corretamente() -> void:
	var golpe := Golpe.new()
	golpe.nome = "Golpe de Teste"
	golpe.dano_base = 30
	golpe.custo_stamina = 15
	golpe.efeito = "veneno"

	assert_str(golpe.nome).is_equal("Golpe de Teste")
	assert_int(golpe.dano_base).is_equal(30)
	assert_int(golpe.custo_stamina).is_equal(15)
	assert_str(golpe.efeito).is_equal("veneno")

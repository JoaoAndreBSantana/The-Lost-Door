
extends GdUnitTestSuite

var _backup_bytes: PackedByteArray
var _tinha_save: bool = false


func before_test() -> void:
	_tinha_save = SaveSistema.existe_save()
	if _tinha_save:
		var f := FileAccess.open(SaveSistema.CAMINHO_SAVE, FileAccess.READ)
		_backup_bytes = f.get_buffer(f.get_length())
		f.close()
	SaveSistema.resetar_dados()


func after_test() -> void:
	if _tinha_save:
		var f := FileAccess.open(SaveSistema.CAMINHO_SAVE, FileAccess.WRITE)
		f.store_buffer(_backup_bytes)
		f.close()
	elif FileAccess.file_exists(SaveSistema.CAMINHO_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveSistema.CAMINHO_SAVE))


func test_salvar_e_carregar_preserva_xp_e_vida() -> void:
	PlayerDados.xp = 250
	PlayerDados.hp_atual = 42
	SaveSistema.salvar()

	
	PlayerDados.xp = 0
	PlayerDados.hp_atual = 0

	SaveSistema.carregar()

	assert_int(PlayerDados.xp).is_equal(250)
	assert_int(PlayerDados.hp_atual).is_equal(42)


func test_resetar_dados_restaura_estado_inicial() -> void:
	PlayerDados.xp = 999
	PlayerDados.vida_upgrades = 3

	SaveSistema.resetar_dados()

	assert_int(PlayerDados.xp).is_equal(0)
	assert_int(PlayerDados.vida_upgrades).is_equal(0)
	assert_int(PlayerDados.hp_maximo).is_equal(PlayerDados.HP_BASE)

	assert_int(PlayerDados.golpes_desbloqueados.size()).is_equal(1)


func test_existe_save_detecta_arquivo() -> void:
	if FileAccess.file_exists(SaveSistema.CAMINHO_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveSistema.CAMINHO_SAVE))

	assert_bool(SaveSistema.existe_save()).is_false()

	SaveSistema.salvar()

	assert_bool(SaveSistema.existe_save()).is_true()

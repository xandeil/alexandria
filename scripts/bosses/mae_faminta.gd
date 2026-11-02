class_name MaeFaminta
extends MaeDosEsporos
## A Mãe Faminta — a Mãe dos Esporos reaproveitada nas Raízes (v0.35, Etapa 6).
## Mesma luta, outro visual (avermelhada) e outra canção de ninar.
## INIMIGA COMUM forte: sem barra de chefe, renasce ao descansar
## (shows_boss_bar = false na cena; uma ou duas por área).

const SPEECH_HUNGRY := "Durma... Durma... e depois seja comida..."


func _on_wake() -> void:
	speech.emit(SPEECH_HUNGRY)
	Sfx.play(&"puff", 0.0, 0.0)
	_set_mode(Mode.DECIDE)
	_decision = 0.8


func _on_died() -> void:
	telegraph.clear()
	_wither_flowers()
	_defeat()

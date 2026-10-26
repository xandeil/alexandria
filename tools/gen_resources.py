"""Gera os .tres de dados: golpes (AttackData), chefes (BossData) e SpriteFrames.

Uso (na raiz do projeto):  python3 tools/gen_resources.py
Depois de gerado, ajuste os números direto no Inspector do Godot (ou aqui e rode de novo).
"""
from __future__ import annotations

import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def write(rel: str, text: str) -> None:
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print("  ", rel)


def gd_value(v) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, float):
        return repr(v)
    if isinstance(v, int):
        return str(v)
    if isinstance(v, tuple):  # cor
        return "Color(%s)" % ", ".join(repr(float(c)) for c in v)
    if isinstance(v, list):
        return "Array[String]([%s])" % ", ".join(gd_value(x) for x in v)
    if isinstance(v, str) and v.startswith("&"):
        return '&"%s"' % v[1:]
    s = str(v).replace("\\", "\\\\").replace('"', '\\"')
    return '"%s"' % s


def resource(script_path: str, class_name: str, props: dict) -> str:
    lines = [
        f'[gd_resource type="Resource" script_class="{class_name}" load_steps=2 format=3]',
        "",
        f'[ext_resource type="Script" path="{script_path}" id="1_script"]',
        "",
        "[resource]",
        'script = ExtResource("1_script")',
    ]
    for key, value in props.items():
        lines.append(f"{key} = {gd_value(value)}")
    return "\n".join(lines) + "\n"


# --- Golpes ------------------------------------------------------------------------
ATTACK_DEFAULTS = {
    "stamina_cost": 0.0, "damage": 10.0, "poise_damage": 10.0, "knockback": 100.0, "is_heavy": False,
    "windup_time": 0.1, "lunge_speed": 150.0, "lunge_time": 0.06, "active_time": 0.08, "recovery_time": 0.2,
    "combo_window": 0.14, "active_during_lunge": False, "track_until": 0.6, "reach": 13.0, "radius": 11.0,
    "hitstop": 0.0, "shake": 0.0, "slash_arc_degrees": 140.0, "slash_radius": 15.0,
    "slash_color": (1.0, 1.0, 1.0, 0.9), "sound": "&swing", "scaling_attribute": "nenhum", "scaling_per_point": 0.0,
}

ATTACKS = {
    # Herói ------------------------------------------------------------------------
    "player_light_1": dict(display_name="Corte", stamina_cost=16.0, damage=20.0, poise_damage=18.0, knockback=90.0,
                           windup_time=0.1, lunge_speed=170.0, lunge_time=0.06, active_time=0.08, recovery_time=0.2,
                           hitstop=0.05, shake=1.5, slash_arc_degrees=140.0, slash_radius=15.0,
                           scaling_attribute="destreza", scaling_per_point=0.03),
    "player_light_2": dict(display_name="Contracorte", stamina_cost=16.0, damage=22.0, poise_damage=18.0, knockback=90.0,
                           windup_time=0.08, lunge_speed=160.0, lunge_time=0.06, active_time=0.08, recovery_time=0.22,
                           hitstop=0.05, shake=1.5, slash_arc_degrees=150.0, slash_radius=15.0,
                           scaling_attribute="destreza", scaling_per_point=0.03),
    "player_light_3": dict(display_name="Estocada", stamina_cost=22.0, damage=30.0, poise_damage=30.0, knockback=140.0,
                           windup_time=0.14, lunge_speed=230.0, lunge_time=0.08, active_time=0.09, recovery_time=0.32,
                           combo_window=0.1, reach=16.0, radius=10.0, hitstop=0.07, shake=2.5,
                           slash_arc_degrees=0.0, slash_radius=14.0, scaling_attribute="destreza", scaling_per_point=0.03),
    "player_heavy": dict(display_name="Golpe Forte", stamina_cost=32.0, damage=46.0, poise_damage=55.0, knockback=180.0,
                         is_heavy=True, windup_time=0.32, lunge_speed=240.0, lunge_time=0.09, active_time=0.1,
                         recovery_time=0.42, combo_window=0.1, reach=15.0, radius=14.0, hitstop=0.1, shake=4.0,
                         slash_arc_degrees=170.0, slash_radius=18.0, slash_color=(1.0, 0.9, 0.75, 0.95),
                         sound="&swing_heavy", scaling_attribute="forca", scaling_per_point=0.035),
    # Soldado Remendado ----------------------------------------------------------------
    "soldado_golpe": dict(display_name="Golpe de cassetete", damage=16.0, poise_damage=20.0, knockback=120.0,
                          windup_time=0.5, lunge_speed=150.0, lunge_time=0.08, active_time=0.1, recovery_time=0.65,
                          track_until=0.6, reach=13.0, radius=10.0, slash_arc_degrees=110.0, slash_radius=14.0,
                          slash_color=(1.0, 0.85, 0.8, 0.85)),
    # Helena Altiva ---------------------------------------------------------------------
    "helena_corte_1": dict(display_name="Corte Duplo I", damage=18.0, poise_damage=20.0, knockback=110.0,
                           windup_time=0.42, lunge_speed=170.0, lunge_time=0.07, active_time=0.09, recovery_time=0.22,
                           track_until=0.7, reach=16.0, radius=13.0, slash_arc_degrees=150.0, slash_radius=19.0,
                           slash_color=(1.0, 0.82, 0.84, 0.95)),
    "helena_corte_2": dict(display_name="Corte Duplo II", damage=20.0, poise_damage=22.0, knockback=120.0,
                           windup_time=0.18, lunge_speed=180.0, lunge_time=0.07, active_time=0.09, recovery_time=0.6,
                           track_until=0.5, reach=16.0, radius=13.0, slash_arc_degrees=160.0, slash_radius=19.0,
                           slash_color=(1.0, 0.82, 0.84, 0.95)),
    "helena_estocada": dict(display_name="Estocada", damage=28.0, poise_damage=30.0, knockback=160.0,
                            windup_time=0.6, lunge_speed=300.0, lunge_time=0.32, active_time=0.06, recovery_time=0.75,
                            active_during_lunge=True, track_until=0.7, reach=12.0, radius=10.0,
                            slash_arc_degrees=0.0, slash_radius=16.0, slash_color=(1.0, 0.75, 0.75, 0.95),
                            sound="&swing_heavy"),
    "helena_furia": dict(display_name="Fúria", damage=12.0, poise_damage=12.0, knockback=70.0,
                         windup_time=0.16, lunge_speed=130.0, lunge_time=0.05, active_time=0.07, recovery_time=0.08,
                         track_until=0.8, reach=15.0, radius=12.0, slash_arc_degrees=120.0, slash_radius=17.0,
                         slash_color=(1.0, 0.7, 0.7, 0.9)),
    "helena_furia_final": dict(display_name="Fúria — golpe final", damage=22.0, poise_damage=30.0, knockback=170.0,
                               is_heavy=True, windup_time=0.25, lunge_speed=200.0, lunge_time=0.08, active_time=0.1,
                               recovery_time=0.7, track_until=0.6, reach=16.0, radius=14.0, slash_arc_degrees=170.0,
                               slash_radius=20.0, slash_color=(1.0, 0.6, 0.6, 0.95), sound="&swing_heavy"),
    "helena_sem_armadura": dict(display_name="Golpe Desesperado", damage=55.0, poise_damage=40.0, knockback=200.0,
                                is_heavy=True, windup_time=0.62, lunge_speed=110.0, lunge_time=0.12, active_time=0.1,
                                recovery_time=0.95, track_until=0.75, reach=11.0, radius=10.0, slash_arc_degrees=90.0,
                                slash_radius=12.0, slash_color=(1.0, 0.55, 0.55, 0.95), sound="&swing_heavy"),
    # Aldir Cornélios -------------------------------------------------------------------
    # Fase 1: windups longos e recuperações longas ("calculado"): fácil de ler, pune caro.
    "aldir_martelada": dict(display_name="Martelada", damage=34.0, poise_damage=45.0, knockback=210.0,
                            is_heavy=True, windup_time=0.8, lunge_speed=110.0, lunge_time=0.1, active_time=0.12,
                            recovery_time=0.95, track_until=0.65, reach=24.0, radius=17.0, slash_arc_degrees=60.0,
                            slash_radius=24.0, slash_color=(1.0, 0.72, 0.5, 0.95), sound="&swing_heavy"),
    "aldir_varredura": dict(display_name="Varredura", damage=26.0, poise_damage=30.0, knockback=190.0,
                            is_heavy=True, windup_time=0.62, lunge_speed=140.0, lunge_time=0.08, active_time=0.14,
                            recovery_time=0.7, track_until=0.55, reach=14.0, radius=26.0, slash_arc_degrees=220.0,
                            slash_radius=30.0, slash_color=(1.0, 0.8, 0.6, 0.9), sound="&swing_heavy"),
    "aldir_empurrao": dict(display_name="Empurrão com o cabo", damage=10.0, poise_damage=15.0, knockback=320.0,
                           windup_time=0.34, lunge_speed=220.0, lunge_time=0.06, active_time=0.08, recovery_time=0.5,
                           track_until=0.7, reach=16.0, radius=12.0, slash_arc_degrees=0.0, slash_radius=16.0,
                           slash_color=(1.0, 0.9, 0.8, 0.85)),
    "aldir_sismico": dict(display_name="Golpe Sísmico", damage=28.0, poise_damage=40.0, knockback=200.0,
                          is_heavy=True, windup_time=0.95, lunge_speed=0.0, lunge_time=0.0, active_time=0.12,
                          recovery_time=0.9, track_until=0.7, reach=26.0, radius=16.0, slash_arc_degrees=40.0,
                          slash_radius=22.0, slash_color=(1.0, 0.6, 0.35, 0.95), sound="&swing_heavy"),
    # Fase 2: windups curtos (e o código ainda sorteia o tempo de cada um).
    "aldir_caos": dict(display_name="Martelada do Caos", damage=30.0, poise_damage=35.0, knockback=200.0,
                       is_heavy=True, windup_time=0.48, lunge_speed=170.0, lunge_time=0.1, active_time=0.12,
                       recovery_time=0.4, track_until=0.75, reach=24.0, radius=17.0, slash_arc_degrees=70.0,
                       slash_radius=24.0, slash_color=(1.0, 0.5, 0.3, 0.95), sound="&swing_heavy"),
    "aldir_caos_final": dict(display_name="Martelada do Caos (final)", damage=38.0, poise_damage=45.0, knockback=230.0,
                             is_heavy=True, windup_time=0.62, lunge_speed=150.0, lunge_time=0.1, active_time=0.14,
                             recovery_time=1.05, track_until=0.7, reach=26.0, radius=19.0, slash_arc_degrees=80.0,
                             slash_radius=26.0, slash_color=(1.0, 0.45, 0.25, 0.95), sound="&swing_heavy"),
    # Prólogo: as crianças (golpes fracos e BEM avisados: dá para atravessar sem revidar)
    "crianca_espetada": dict(display_name="Espetada de madeira", damage=7.0, poise_damage=8.0, knockback=80.0,
                             windup_time=0.42, lunge_speed=150.0, lunge_time=0.07, active_time=0.08,
                             recovery_time=0.45, track_until=0.6, reach=10.0, radius=8.0,
                             slash_arc_degrees=100.0, slash_radius=11.0, slash_color=(1.0, 0.95, 0.85, 0.75),
                             sound="&swing_small"),
    "adolescente_golpe": dict(display_name="Golpe de espada de madeira", damage=11.0, poise_damage=14.0,
                              knockback=110.0, windup_time=0.5, lunge_speed=170.0, lunge_time=0.08,
                              active_time=0.09, recovery_time=0.55, track_until=0.6, reach=12.0, radius=10.0,
                              slash_arc_degrees=140.0, slash_radius=14.0, slash_color=(1.0, 0.95, 0.85, 0.8),
                              sound="&swing_small"),
    # A Governanta (mini-chefe do prólogo)
    "governanta_chaves": dict(display_name="Molho de chaves", damage=20.0, poise_damage=25.0, knockback=150.0,
                              windup_time=0.55, lunge_speed=120.0, lunge_time=0.08, active_time=0.12,
                              recovery_time=0.6, track_until=0.6, reach=18.0, radius=16.0, slash_arc_degrees=200.0,
                              slash_radius=24.0, slash_color=(0.95, 0.85, 0.55, 0.9), sound="&swing_heavy"),
    "governanta_chaves_volta": dict(display_name="Molho de chaves (volta)", damage=18.0, poise_damage=22.0,
                                    knockback=150.0, windup_time=0.25, lunge_speed=120.0, lunge_time=0.08,
                                    active_time=0.12, recovery_time=0.75, track_until=0.5, reach=18.0, radius=16.0,
                                    slash_arc_degrees=200.0, slash_radius=24.0,
                                    slash_color=(0.95, 0.85, 0.55, 0.9), sound="&swing_heavy"),
    "governanta_abraco": dict(display_name="Abraço", unblockable=True, damage=26.0, poise_damage=30.0, knockback=190.0,
                              is_heavy=True, windup_time=0.7, lunge_speed=270.0, lunge_time=0.32,
                              active_time=0.06, recovery_time=0.95, active_during_lunge=True, track_until=0.7,
                              reach=12.0, radius=13.0, slash_arc_degrees=0.0, slash_radius=16.0,
                              slash_color=(1.0, 0.92, 0.92, 0.95), sound="&swing_heavy"),
    # Cidade: Cão de Guerra, Atirador de Telhado, Civil Cinzento
    "cao_mordida": dict(display_name="Mordida", damage=12.0, poise_damage=12.0, knockback=90.0,
                        windup_time=0.32, lunge_speed=280.0, lunge_time=0.12, active_time=0.06,
                        recovery_time=0.3, active_during_lunge=True, track_until=0.7, reach=10.0, radius=9.0,
                        slash_arc_degrees=60.0, slash_radius=12.0, slash_color=(1.0, 0.75, 0.7, 0.85),
                        sound="&bark"),
    "atirador_coronha": dict(display_name="Coronhada", damage=14.0, poise_damage=16.0, knockback=140.0,
                             windup_time=0.6, lunge_speed=120.0, lunge_time=0.06, active_time=0.09,
                             recovery_time=0.7, track_until=0.6, reach=12.0, radius=10.0,
                             slash_arc_degrees=110.0, slash_radius=14.0, slash_color=(1.0, 0.9, 0.8, 0.85)),
    "civil_agarrao": dict(display_name="Agarrão", unblockable=True, damage=9.0, poise_damage=10.0, knockback=60.0,
                          windup_time=0.55, lunge_speed=120.0, lunge_time=0.08, active_time=0.1,
                          recovery_time=0.7, track_until=0.6, reach=11.0, radius=9.0,
                          slash_arc_degrees=80.0, slash_radius=12.0, slash_color=(0.85, 0.85, 0.85, 0.8),
                          sound="&swing_small"),
    # Mini-chefes da Cidade
    "sargento_sabre": dict(display_name="Sabre", damage=16.0, poise_damage=20.0, knockback=120.0,
                           windup_time=0.42, lunge_speed=170.0, lunge_time=0.07, active_time=0.09,
                           recovery_time=0.35, track_until=0.65, reach=14.0, radius=12.0,
                           slash_arc_degrees=140.0, slash_radius=16.0, slash_color=(1.0, 0.85, 0.8, 0.9)),
    "sargento_estocada": dict(display_name="Estocada de oficial", damage=22.0, poise_damage=26.0, knockback=150.0,
                              windup_time=0.55, lunge_speed=260.0, lunge_time=0.16, active_time=0.06,
                              recovery_time=0.6, active_during_lunge=True, track_until=0.7, reach=12.0,
                              radius=10.0, slash_arc_degrees=0.0, slash_radius=15.0,
                              slash_color=(1.0, 0.8, 0.75, 0.95), sound="&swing_heavy"),
    "couraca_clava": dict(display_name="Clava", damage=32.0, poise_damage=45.0, knockback=210.0, is_heavy=True,
                          windup_time=0.9, lunge_speed=90.0, lunge_time=0.1, active_time=0.12,
                          recovery_time=1.1, track_until=0.6, reach=22.0, radius=16.0,
                          slash_arc_degrees=70.0, slash_radius=24.0, slash_color=(1.0, 0.75, 0.55, 0.95),
                          sound="&swing_heavy"),
    "couraca_giro": dict(display_name="Giro", damage=24.0, poise_damage=35.0, knockback=220.0, is_heavy=True,
                         windup_time=0.85, lunge_speed=0.0, lunge_time=0.0, active_time=0.18,
                         recovery_time=0.9, track_until=0.0, reach=0.0, radius=34.0,
                         slash_arc_degrees=360.0, slash_radius=34.0, slash_color=(1.0, 0.75, 0.55, 0.9),
                         sound="&swing_heavy"),
    # Bosque do Sono Eterno
    "sonambulo_bracos": dict(display_name="Braços estendidos", damage=18.0, poise_damage=18.0, knockback=110.0,
                             windup_time=0.6, lunge_speed=60.0, lunge_time=0.1, active_time=0.12,
                             recovery_time=0.6, track_until=0.4, reach=12.0, radius=11.0,
                             slash_arc_degrees=90.0, slash_radius=14.0, slash_color=(0.85, 0.82, 0.95, 0.8),
                             sound="&swing_small"),
    # Raízes da Fome -------------------------------------------------------------------
    "boca_mordida": dict(display_name="Mordida de Raiz", damage=16.0, poise_damage=14.0, knockback=90.0,
                         windup_time=0.35, lunge_speed=0.0, lunge_time=0.04, active_time=0.1, recovery_time=0.6,
                         track_until=0.5, reach=12.0, radius=10.0, slash_arc_degrees=90.0, slash_radius=12.0,
                         slash_color=(0.95, 0.5, 0.45, 0.85), sound="&chomp"),
    "inchado_tapa": dict(display_name="Tapa inchado", damage=18.0, poise_damage=22.0, knockback=140.0,
                         windup_time=0.75, lunge_speed=80.0, lunge_time=0.1, active_time=0.1, recovery_time=0.8,
                         track_until=0.6, reach=13.0, radius=12.0, slash_arc_degrees=120.0, slash_radius=15.0,
                         slash_color=(0.95, 0.65, 0.6, 0.85), sound="&swing_heavy"),
    "colhedor_foice": dict(display_name="Foice", damage=22.0, poise_damage=26.0, knockback=150.0,
                           windup_time=0.7, lunge_speed=120.0, lunge_time=0.08, active_time=0.12, recovery_time=0.75,
                           track_until=0.6, reach=8.0, radius=26.0, slash_arc_degrees=200.0, slash_radius=28.0,
                           slash_color=(0.9, 0.92, 0.85, 0.9), sound="&swing_heavy"),
    "colhedor_giro": dict(display_name="Ceifa em volta", damage=20.0, poise_damage=24.0, knockback=170.0,
                          windup_time=0.85, lunge_speed=0.0, lunge_time=0.04, active_time=0.18, recovery_time=0.9,
                          track_until=0.3, reach=0.0, radius=30.0, slash_arc_degrees=340.0, slash_radius=28.0,
                          slash_color=(0.9, 0.92, 0.85, 0.9), sound="&swing_heavy"),
    "larva_mordida": dict(display_name="Mordida de Larva", damage=5.0, poise_damage=4.0, knockback=40.0,
                          windup_time=0.3, lunge_speed=110.0, lunge_time=0.08, active_time=0.08, recovery_time=0.4,
                          track_until=0.7, reach=7.0, radius=7.0, slash_arc_degrees=60.0, slash_radius=8.0,
                          slash_color=(0.95, 0.9, 0.75, 0.7), sound="&swing_small"),
    "banqueteiro_cutelo": dict(display_name="Cutelo", damage=28.0, poise_damage=35.0, knockback=190.0, is_heavy=True,
                               windup_time=0.75, lunge_speed=120.0, lunge_time=0.1, active_time=0.12, recovery_time=0.8,
                               track_until=0.6, reach=22.0, radius=17.0, slash_arc_degrees=70.0, slash_radius=22.0,
                               slash_color=(0.92, 0.93, 0.9, 0.95), hitstop=0.08, shake=4.0, sound="&swing_heavy"),
    "banqueteiro_concha": dict(display_name="Concha", damage=20.0, poise_damage=24.0, knockback=220.0,
                               windup_time=0.55, lunge_speed=140.0, lunge_time=0.08, active_time=0.12, recovery_time=0.6,
                               track_until=0.6, reach=18.0, radius=18.0, slash_arc_degrees=190.0, slash_radius=24.0,
                               slash_color=(0.85, 0.85, 0.8, 0.9), sound="&swing_heavy"),
    "ninhada_investida": dict(display_name="Rolar por cima", damage=20.0, poise_damage=24.0, knockback=160.0,
                              windup_time=0.7, lunge_speed=220.0, lunge_time=0.22, active_time=0.06, recovery_time=0.9,
                              active_during_lunge=True, track_until=0.6, reach=10.0, radius=16.0,
                              slash_arc_degrees=0.0, slash_radius=0.0, sound="&splat"),
    "mabel_tapa": dict(display_name="Tapa da Anfitriã", damage=34.0, poise_damage=50.0, knockback=250.0, is_heavy=True,
                       windup_time=0.95, lunge_speed=90.0, lunge_time=0.1, active_time=0.12, recovery_time=1.0,
                       track_until=0.6, reach=30.0, radius=24.0, slash_arc_degrees=120.0, slash_radius=34.0,
                       slash_color=(0.95, 0.75, 0.68, 0.95), hitstop=0.1, shake=5.0, sound="&swing_heavy"),
    "mabel_tapa_volta": dict(display_name="Tapa de volta", damage=30.0, poise_damage=45.0, knockback=240.0, is_heavy=True,
                             windup_time=0.45, lunge_speed=90.0, lunge_time=0.1, active_time=0.12, recovery_time=1.1,
                             track_until=0.5, reach=30.0, radius=24.0, slash_arc_degrees=120.0, slash_radius=34.0,
                             slash_color=(0.95, 0.75, 0.68, 0.95), hitstop=0.1, shake=5.0, sound="&swing_heavy"),
    "mabel_ventre": dict(display_name="Mordida do Ventre", damage=40.0, poise_damage=60.0, knockback=200.0, is_heavy=True,
                         windup_time=0.7, lunge_speed=150.0, lunge_time=0.12, active_time=0.12, recovery_time=1.0,
                         track_until=0.6, reach=20.0, radius=20.0, slash_arc_degrees=100.0, slash_radius=24.0,
                         slash_color=(0.9, 0.3, 0.3, 0.95), hitstop=0.1, shake=5.0, sound="&chomp"),
    # Forjas Ocas ---------------------------------------------------------------------
    "automato_golpe": dict(display_name="Martelo de bronze", damage=26.0, poise_damage=34.0, knockback=190.0, is_heavy=True,
                           windup_time=0.85, lunge_speed=90.0, lunge_time=0.1, active_time=0.12, recovery_time=0.9,
                           track_until=0.6, reach=16.0, radius=14.0, slash_arc_degrees=120.0, slash_radius=20.0,
                           slash_color=(1.0, 0.8, 0.5, 0.95), hitstop=0.06, shake=3.0, sound="&swing_heavy"),
    "minerador_1": dict(display_name="Picareta I", damage=12.0, poise_damage=14.0, knockback=80.0,
                        windup_time=0.45, lunge_speed=120.0, lunge_time=0.06, active_time=0.08, recovery_time=0.15,
                        track_until=0.7, reach=13.0, radius=11.0, slash_arc_degrees=100.0, slash_radius=15.0,
                        slash_color=(0.85, 0.88, 0.9, 0.85)),
    "minerador_2": dict(display_name="Picareta II", damage=12.0, poise_damage=14.0, knockback=80.0,
                        windup_time=0.3, lunge_speed=120.0, lunge_time=0.06, active_time=0.08, recovery_time=0.15,
                        track_until=0.7, reach=13.0, radius=11.0, slash_arc_degrees=100.0, slash_radius=15.0,
                        slash_color=(0.85, 0.88, 0.9, 0.85)),
    "minerador_3": dict(display_name="Picareta III", damage=22.0, poise_damage=30.0, knockback=170.0, is_heavy=True,
                        windup_time=0.6, lunge_speed=180.0, lunge_time=0.1, active_time=0.1, recovery_time=1.0,
                        track_until=0.6, reach=14.0, radius=12.0, slash_arc_degrees=60.0, slash_radius=17.0,
                        slash_color=(0.9, 0.9, 0.95, 0.95), hitstop=0.06, shake=3.0, sound="&swing_heavy"),
    "durgan_chave": dict(display_name="Chave-martelo", damage=26.0, poise_damage=30.0, knockback=180.0,
                         windup_time=0.6, lunge_speed=140.0, lunge_time=0.08, active_time=0.1, recovery_time=0.6,
                         track_until=0.6, reach=20.0, radius=16.0, slash_arc_degrees=150.0, slash_radius=24.0,
                         slash_color=(0.7, 0.9, 1.0, 0.95), sound="&swing_heavy"),
    "durgan_martelada": dict(display_name="Martelada elétrica", damage=30.0, poise_damage=45.0, knockback=220.0, is_heavy=True,
                             windup_time=0.9, lunge_speed=60.0, lunge_time=0.08, active_time=0.12, recovery_time=0.9,
                             track_until=0.6, reach=22.0, radius=18.0, slash_arc_degrees=10.0, slash_radius=22.0,
                             slash_color=(0.75, 0.92, 1.0, 0.95), hitstop=0.1, shake=5.0, sound="&swing_heavy"),
    "durgan_copia_leve_1": dict(display_name="Seu corte (cópia)", damage=16.0, poise_damage=18.0, knockback=100.0,
                                windup_time=0.3, lunge_speed=180.0, lunge_time=0.06, active_time=0.08, recovery_time=0.18,
                                track_until=0.6, reach=14.0, radius=12.0, slash_arc_degrees=140.0, slash_radius=17.0,
                                slash_color=(0.9, 0.95, 1.0, 0.9)),
    "durgan_copia_leve_2": dict(display_name="Seu contracorte (cópia)", damage=17.0, poise_damage=18.0, knockback=100.0,
                                windup_time=0.22, lunge_speed=170.0, lunge_time=0.06, active_time=0.08, recovery_time=0.2,
                                track_until=0.5, reach=14.0, radius=12.0, slash_arc_degrees=150.0, slash_radius=17.0,
                                slash_color=(0.9, 0.95, 1.0, 0.9)),
    "durgan_copia_leve_3": dict(display_name="Sua estocada (cópia)", damage=22.0, poise_damage=28.0, knockback=150.0,
                                windup_time=0.35, lunge_speed=240.0, lunge_time=0.08, active_time=0.09, recovery_time=0.6,
                                track_until=0.6, reach=16.0, radius=10.0, slash_arc_degrees=0.0, slash_radius=15.0,
                                slash_color=(0.9, 0.95, 1.0, 0.95)),
    "durgan_copia_forte": dict(display_name="Seu golpe forte (cópia)", damage=40.0, poise_damage=55.0, knockback=220.0, is_heavy=True,
                               windup_time=0.55, lunge_speed=240.0, lunge_time=0.09, active_time=0.1, recovery_time=0.8,
                               track_until=0.6, reach=16.0, radius=15.0, slash_arc_degrees=170.0, slash_radius=20.0,
                               slash_color=(0.95, 0.97, 1.0, 0.95), hitstop=0.1, shake=4.0, sound="&swing_heavy"),
    "durgan_estocada": dict(display_name="Seu dash (cópia)", damage=24.0, poise_damage=26.0, knockback=170.0,
                            windup_time=0.4, lunge_speed=300.0, lunge_time=0.2, active_time=0.05, recovery_time=0.7,
                            active_during_lunge=True, track_until=0.6, reach=12.0, radius=11.0,
                            slash_arc_degrees=0.0, slash_radius=15.0, slash_color=(0.85, 0.92, 1.0, 0.9),
                            sound="&swing_heavy"),
    "vigia_martelo": dict(display_name="Martelada do Vigia", damage=34.0, poise_damage=55.0, knockback=240.0, is_heavy=True,
                          windup_time=1.05, lunge_speed=40.0, lunge_time=0.1, active_time=0.14,
                          recovery_time=1.0, track_until=0.55, reach=30.0, radius=22.0,
                          slash_arc_degrees=10.0, slash_radius=24.0, slash_color=(0.8, 0.85, 0.7, 0.9),
                          hitstop=0.1, shake=5.0, sound="&swing_heavy"),
    "vigia_varredura": dict(display_name="Varredura", damage=24.0, poise_damage=40.0, knockback=200.0, is_heavy=True,
                            windup_time=0.8, lunge_speed=50.0, lunge_time=0.08, active_time=0.16,
                            recovery_time=0.8, track_until=0.6, reach=16.0, radius=28.0,
                            slash_arc_degrees=200.0, slash_radius=34.0, slash_color=(0.8, 0.85, 0.7, 0.9),
                            hitstop=0.08, shake=3.0, sound="&swing_heavy"),
    # Montanha Carbonizada --------------------------------------------------------------
    "atirador_baioneta": dict(display_name="Coronha de fogo", damage=14.0, poise_damage=16.0, knockback=140.0,
                              windup_time=0.4, lunge_speed=110.0, lunge_time=0.08, active_time=0.08, recovery_time=0.5,
                              track_until=0.6, reach=13.0, radius=11.0, slash_arc_degrees=110.0, slash_radius=16.0,
                              slash_color=(1.0, 0.7, 0.4, 0.9), sound="&swing"),
    "bestial_investida": dict(display_name="Investida", damage=22.0, poise_damage=34.0, knockback=220.0, is_heavy=True,
                              windup_time=0.05, lunge_speed=330.0, lunge_time=0.42, active_time=0.06, recovery_time=0.5,
                              active_during_lunge=True, track_until=0.0, reach=14.0, radius=13.0,
                              slash_arc_degrees=0.0, slash_radius=16.0, slash_color=(1.0, 0.8, 0.6, 0.9),
                              sound="&hooves"),
    "bestial_mordida": dict(display_name="Mordida", damage=16.0, poise_damage=18.0, knockback=110.0,
                            windup_time=0.45, lunge_speed=160.0, lunge_time=0.1, active_time=0.08, recovery_time=0.55,
                            track_until=0.6, reach=16.0, radius=13.0, slash_arc_degrees=70.0, slash_radius=18.0,
                            slash_color=(1.0, 0.75, 0.7, 0.9), sound="&chomp"),
    "matriarca_investida": dict(display_name="Investida da Matriarca", damage=32.0, poise_damage=50.0, knockback=260.0,
                                is_heavy=True, windup_time=0.05, lunge_speed=360.0, lunge_time=0.5, active_time=0.06,
                                recovery_time=0.6, active_during_lunge=True, track_until=0.0, reach=22.0, radius=22.0,
                                slash_arc_degrees=0.0, slash_radius=26.0, slash_color=(1.0, 0.8, 0.6, 0.9),
                                hitstop=0.08, shake=5.0, sound="&hooves"),
    "matriarca_mordida": dict(display_name="Mordida da Matriarca", damage=26.0, poise_damage=34.0, knockback=170.0,
                              is_heavy=True, windup_time=0.6, lunge_speed=150.0, lunge_time=0.12, active_time=0.1,
                              recovery_time=0.8, track_until=0.6, reach=26.0, radius=20.0, slash_arc_degrees=80.0,
                              slash_radius=28.0, slash_color=(1.0, 0.75, 0.7, 0.95), hitstop=0.08, shake=4.0,
                              sound="&chomp"),
    "capitao_escudada": dict(display_name="Escudada", damage=18.0, poise_damage=40.0, knockback=230.0, is_heavy=True,
                             windup_time=0.55, lunge_speed=200.0, lunge_time=0.14, active_time=0.08, recovery_time=0.7,
                             active_during_lunge=True, track_until=0.6, reach=16.0, radius=15.0,
                             slash_arc_degrees=90.0, slash_radius=20.0, slash_color=(0.9, 0.8, 0.6, 0.9),
                             hitstop=0.07, shake=3.0, sound="&clang"),
    "rachel_garra": dict(display_name="Garra", damage=30.0, poise_damage=40.0, knockback=210.0, is_heavy=True,
                         windup_time=0.65, lunge_speed=120.0, lunge_time=0.12, active_time=0.1, recovery_time=0.55,
                         combo_window=0.2, track_until=0.6, reach=34.0, radius=30.0, slash_arc_degrees=130.0,
                         slash_radius=40.0, slash_color=(1.0, 0.6, 0.35, 0.95), hitstop=0.09, shake=5.0,
                         sound="&swing_heavy"),
    "rachel_mordida": dict(display_name="Mordida do Dragão", damage=38.0, poise_damage=55.0, knockback=240.0,
                           is_heavy=True, windup_time=0.5, lunge_speed=200.0, lunge_time=0.14, active_time=0.1,
                           recovery_time=1.0, track_until=0.5, reach=36.0, radius=24.0, slash_arc_degrees=70.0,
                           slash_radius=36.0, slash_color=(1.0, 0.5, 0.3, 0.95), hitstop=0.1, shake=6.0,
                           sound="&chomp"),
    # Domínio Congelado ------------------------------------------------------------------
    "estatua_golpe": dict(display_name="Livro de pedra", damage=22.0, poise_damage=30.0, knockback=170.0, is_heavy=True,
                          windup_time=0.3, lunge_speed=140.0, lunge_time=0.1, active_time=0.08, recovery_time=0.7,
                          track_until=0.5, reach=15.0, radius=13.0, slash_arc_degrees=110.0, slash_radius=18.0,
                          slash_color=(0.9, 0.94, 1.0, 0.95), hitstop=0.07, shake=3.0, sound="&swing_heavy"),
    "curadora_bengala": dict(display_name="Bengala", damage=16.0, poise_damage=18.0, knockback=120.0,
                             windup_time=0.45, lunge_speed=170.0, lunge_time=0.1, active_time=0.08, recovery_time=0.5,
                             track_until=0.6, reach=20.0, radius=12.0, slash_arc_degrees=40.0, slash_radius=22.0,
                             slash_color=(1.0, 0.9, 0.6, 0.9), sound="&swing"),
    "curadora_catalogo": dict(display_name="Catalogar", damage=34.0, poise_damage=50.0, knockback=220.0, is_heavy=True,
                              unblockable=True, windup_time=0.7, lunge_speed=60.0, lunge_time=0.08, active_time=0.1,
                              recovery_time=0.9, track_until=0.6, reach=18.0, radius=16.0, slash_arc_degrees=120.0,
                              slash_radius=24.0, slash_color=(0.85, 0.95, 1.0, 0.95), hitstop=0.1, shake=5.0,
                              sound="&swing_heavy"),
    "golem_varredura": dict(display_name="Braço-estante", damage=28.0, poise_damage=45.0, knockback=230.0, is_heavy=True,
                            windup_time=0.9, lunge_speed=50.0, lunge_time=0.1, active_time=0.14, recovery_time=1.0,
                            track_until=0.6, reach=26.0, radius=30.0, slash_arc_degrees=180.0, slash_radius=40.0,
                            slash_color=(0.8, 0.7, 0.6, 0.95), hitstop=0.09, shake=5.0, sound="&swing_heavy"),
    "cassian_cajado": dict(display_name="Cajado do Arconte", damage=22.0, poise_damage=28.0, knockback=180.0,
                           windup_time=0.5, lunge_speed=150.0, lunge_time=0.1, active_time=0.1, recovery_time=0.6,
                           track_until=0.6, reach=20.0, radius=18.0, slash_arc_degrees=140.0, slash_radius=26.0,
                           slash_color=(0.7, 0.9, 1.0, 0.95), hitstop=0.08, shake=4.0, sound="&swing_heavy"),
    # O Núcleo -------------------------------------------------------------------------
    "cavaleiro_corte_1": dict(display_name="Espadão I", damage=24.0, poise_damage=30.0, knockback=150.0,
                              windup_time=0.55, lunge_speed=150.0, lunge_time=0.12, active_time=0.1, recovery_time=0.25,
                              combo_window=0.2, track_until=0.6, reach=26.0, radius=22.0, slash_arc_degrees=150.0,
                              slash_radius=32.0, slash_color=(0.95, 0.9, 0.75, 0.95), hitstop=0.08, shake=4.0,
                              sound="&swing_heavy"),
    "cavaleiro_corte_2": dict(display_name="Espadão II", damage=26.0, poise_damage=30.0, knockback=150.0,
                              windup_time=0.45, lunge_speed=160.0, lunge_time=0.12, active_time=0.1, recovery_time=0.25,
                              combo_window=0.2, track_until=0.6, reach=26.0, radius=22.0, slash_arc_degrees=150.0,
                              slash_radius=32.0, slash_color=(0.95, 0.9, 0.75, 0.95), hitstop=0.08, shake=4.0,
                              sound="&swing_heavy"),
    "cavaleiro_corte_3": dict(display_name="A Promessa", damage=38.0, poise_damage=60.0, knockback=250.0, is_heavy=True,
                              windup_time=0.85, lunge_speed=220.0, lunge_time=0.16, active_time=0.12, recovery_time=1.0,
                              track_until=0.5, reach=30.0, radius=26.0, slash_arc_degrees=200.0, slash_radius=40.0,
                              slash_color=(1.0, 0.92, 0.6, 0.95), hitstop=0.12, shake=6.0, sound="&swing_heavy"),
    # --- Armas de chefe (v0.20): golpes proprios ---------------------------------------
    "arma_estocada_desolada": dict(display_name="Estocada Desolada", stamina_cost=24.0, damage=34.0, poise_damage=30.0,
        knockback=130.0, is_heavy=True, windup_time=0.14, lunge_speed=340.0, lunge_time=0.14, active_time=0.06,
        recovery_time=0.3, active_during_lunge=True, reach=14.0, radius=11.0, hitstop=0.07, shake=2.5,
        slash_arc_degrees=0.0, slash_radius=14.0, slash_color=(1.0, 0.75, 0.78, 0.9), sound="&swing_heavy"),
    "arma_pilar_impacto": dict(display_name="Impacto do Pilar", stamina_cost=40.0, damage=58.0, poise_damage=80.0,
        knockback=200.0, is_heavy=True, windup_time=0.5, lunge_speed=120.0, lunge_time=0.08, active_time=0.1,
        recovery_time=0.55, combo_window=0.08, reach=16.0, radius=16.0, hitstop=0.14, shake=6.0,
        slash_arc_degrees=90.0, slash_radius=18.0, slash_color=(1.0, 0.72, 0.4, 0.9), sound="&swing_heavy"),
    "arma_presa_corte": dict(display_name="Corte de Caelis", stamina_cost=36.0, damage=50.0, poise_damage=55.0,
        knockback=170.0, is_heavy=True, windup_time=0.38, lunge_speed=200.0, lunge_time=0.09, active_time=0.1,
        recovery_time=0.48, combo_window=0.1, reach=16.0, radius=15.0, hitstop=0.1, shake=4.0,
        slash_arc_degrees=170.0, slash_radius=19.0, slash_color=(1.0, 0.55, 0.2, 0.95), sound="&fire_breath"),
    "arma_fuso_estocada": dict(display_name="Estocada do Fuso", stamina_cost=30.0, damage=40.0, poise_damage=40.0,
        knockback=150.0, is_heavy=True, windup_time=0.26, lunge_speed=260.0, lunge_time=0.1, active_time=0.09,
        recovery_time=0.38, combo_window=0.1, reach=21.0, radius=10.0, hitstop=0.08, shake=3.0,
        slash_arc_degrees=0.0, slash_radius=16.0, slash_color=(0.75, 0.9, 1.0, 0.9), sound="&swing_heavy"),
    "arma_virote": dict(display_name="Virote", stamina_cost=14.0, damage=18.0, poise_damage=12.0, knockback=70.0,
        windup_time=0.12, lunge_speed=0.0, lunge_time=0.02, active_time=0.05, recovery_time=0.3, combo_window=0.12,
        reach=0.0, radius=1.0, slash_arc_degrees=0.0, sound="&shot"),
    "arma_virote_carregado": dict(display_name="Virote Carregado", stamina_cost=28.0, damage=34.0, poise_damage=25.0,
        knockback=90.0, is_heavy=True, windup_time=0.4, lunge_speed=0.0, lunge_time=0.02, active_time=0.05,
        recovery_time=0.45, combo_window=0.1, reach=0.0, radius=1.0, slash_arc_degrees=0.0, sound="&zap"),
    "arma_flecha": dict(display_name="Flecha", stamina_cost=12.0, damage=15.0, poise_damage=8.0, knockback=50.0,
        windup_time=0.18, lunge_speed=0.0, lunge_time=0.02, active_time=0.05, recovery_time=0.25, combo_window=0.12,
        reach=0.0, radius=1.0, slash_arc_degrees=0.0, sound="&swing_small"),
    "arma_flecha_polen": dict(display_name="Flecha de Pólen", stamina_cost=30.0, damage=20.0, poise_damage=10.0,
        knockback=40.0, is_heavy=True, windup_time=0.45, lunge_speed=0.0, lunge_time=0.02, active_time=0.05,
        recovery_time=0.4, combo_window=0.1, reach=0.0, radius=1.0, slash_arc_degrees=0.0, sound="&swing_small"),
    "arma_giro_cobaia": dict(display_name="Giro da Cobaia", stamina_cost=30.0, damage=30.0, poise_damage=35.0,
        knockback=150.0, is_heavy=True, windup_time=0.3, lunge_speed=80.0, lunge_time=0.06, active_time=0.14,
        recovery_time=0.42, combo_window=0.08, reach=0.0, radius=24.0, hitstop=0.08, shake=3.0,
        slash_arc_degrees=360.0, slash_radius=20.0, sound="&swing_heavy"),
    "arma_frenesi_voragem": dict(display_name="Frenesi da Vorágine", stamina_cost=26.0, damage=16.0, poise_damage=14.0,
        knockback=60.0, is_heavy=True, windup_time=0.12, lunge_speed=300.0, lunge_time=0.16, active_time=0.06,
        recovery_time=0.3, active_during_lunge=True, reach=12.0, radius=11.0, hitstop=0.05, shake=1.5,
        slash_arc_degrees=0.0, slash_radius=13.0, slash_color=(0.9, 0.3, 0.35, 0.9), sound="&swing_small"),
    "arma_virote_forte": dict(display_name="Virote Pesado", stamina_cost=22.0, damage=28.0, poise_damage=22.0,
        knockback=100.0, is_heavy=True, windup_time=0.3, lunge_speed=0.0, lunge_time=0.02, active_time=0.05,
        recovery_time=0.4, combo_window=0.1, reach=0.0, radius=1.0, slash_arc_degrees=0.0, sound="&shot"),
    "arma_flecha_forte": dict(display_name="Flecha Tensa", stamina_cost=20.0, damage=25.0, poise_damage=14.0,
        knockback=70.0, is_heavy=True, windup_time=0.32, lunge_speed=0.0, lunge_time=0.02, active_time=0.05,
        recovery_time=0.32, combo_window=0.1, reach=0.0, radius=1.0, slash_arc_degrees=0.0, sound="&swing_small"),
    "arma_ancora_fincada": dict(display_name="Âncora Fincada", stamina_cost=42.0, damage=52.0, poise_damage=70.0,
        knockback=120.0, is_heavy=True, windup_time=0.55, lunge_speed=100.0, lunge_time=0.08, active_time=0.1,
        recovery_time=0.6, combo_window=0.08, reach=16.0, radius=15.0, hitstop=0.12, shake=5.0,
        slash_arc_degrees=60.0, slash_radius=17.0, slash_color=(0.95, 0.85, 0.5, 0.9), sound="&gravity"),
}

# --- Os Sete Pecados (da Bíblia) ------------------------------------------------------------
BOSSES = {
    "helena": dict(
        id="helena", display_name="Helena Altiva", title="A Cavaleira Desolada", sin="Luxúria", sin_meaning="Apego",
        race="Humana", attribute="Destreza", area="Teatro Alexandria (hub)", scaling="Destreza",
        suggested_order="Última dos Sete", memory_reward=2000, implemented=True,
        unique_mechanic="Três fases; a armadura cai com o tempo (e com os golpes) e ela fica mais agressiva; a última fase é sem armadura e com dano altíssimo.",
        phases=["Fase 1 — A Cavaleira Técnica: confiante, rápida, elegante e precisa.",
                "Fase 2 — O Desespero (metade da vida): muito mais rápida e agressiva; emoção no lugar da técnica.",
                "Fase 3 — A Mulher Sem Armadura (depois de derrotada): sem espada e sem armadura. Alcance e velocidade menores, dano altíssimo."],
        history="Helena fazia parte da agência que protegia o Projeto Alexandria. Ela e o marido eram os melhores agentes. Quando o governo invadiu, os dois foram a linha de defesa. O marido abandonou o posto por um instante e morreu tentando corrigir o erro. Helena nunca superou: passou a acreditar que o problema do mundo era o apego e que ninguém jamais ocuparia o lugar de outro. Permaneceu no Teatro guardando o centro da ilha. Ela não protege o projeto; protege a memória.",
        meaning="Luxúria aqui é apego emocional: não aceitar a perda."),
    "aldir": dict(
        id="aldir", display_name="Aldir Cornélios", title="O Detentor do Caos", sin="Ira", sin_meaning="Impotência",
        race="Humano", attribute="Força", area="Cidade Estilhaçada", scaling="Força", suggested_order="1ª",
        memory_reward=1200, implemented=True,
        unique_mechanic="Arena destrutível: o martelo abre buracos e derruba coberturas.",
        phases=["Fase 1 — O Soldado que Ainda Pensa: martelo de guerra gigante, golpes pesados e calculados que quebram o chão, técnica militar e algumas falas.",
                "Fase 2 — O Caos (metade da vida): a razão some; golpes brutais e imprevisíveis; destrói o cenário, inclusive as coberturas da fase 1."],
        history="Soldado de alto escalão aposentado aos 35 anos, convencido de que o mundo não precisava mudar. Afastou-se da família e não ouviu. Quando entendeu o perigo, Rachel já tinha queimado a cidade. A cidade foi destruída por Rachel; o que sobrou foi destruído por Aldir. Ele não distingue mais inimigo de aliado.",
        meaning="Ira é impotência transformada em violência: não conseguiu proteger ninguém, então decidiu destruir tudo."),
    "nyssa": dict(
        id="nyssa", display_name="Nyssa Lumevel", title="A Que Não Desperta", sin="Preguiça", sin_meaning="Desistência",
        race="Fada", attribute="Sono", area="Bosque do Sono Eterno", scaling="Fé", suggested_order="2ª",
        memory_reward=1300, implemented=True, unique_mechanic="Barra de Sonolência: ficar parado, curar ou ficar perto das flores faz o jogador dormir.",
        phases=["Fase 1 — O Sonho Leve: flutua deitada e quase não ataca; o bosque luta por ela. A Sonolência enche se o jogador fica parado; atacar esvazia.",
                "Fase 2 — O Pesadelo (metade da vida): áreas escuras do chão somem; invoca ecos fracos de chefes já derrotados, cada um com um único ataque."],
        history="Nyssa e a Fada do Teatro eram irmãs, fadas-sentinela das cápsulas: Nyssa fazia as cobaias dormirem; a irmã as acordava. Ao ver o que cada morte tirava, Nyssa decidiu que acordar alguém era crueldade e deixou todos dormindo, inclusive ela mesma.",
        meaning="Preguiça não é cansaço do corpo; é desistir de mudar porque mudar dói."),
    "mabel": dict(
        id="mabel", display_name="Mabel Vorágine", title="A Fome Que Lembra", sin="Gula", sin_meaning="Vazio",
        race="Giganta", attribute="Sangue", area="Raízes da Fome", scaling="Sorte", suggested_order="3ª",
        memory_reward=1400, implemented=True, unique_mechanic="Agarra, engole e drena memórias; regenera comendo lacaios. Preso: toque rápido no Ataque para escapar.",
        phases=["Fase 1 — A Anfitriã: lenta e enorme; tapas, frutos de carne que explodem e um agarrão que drena memórias.",
                "Fase 2 — A Vorágine (metade da vida): come lacaios e raízes para se curar; uma boca no ventre é o ponto fraco; cortar as raízes interrompe a cura."],
        history="Mabel cuidava das estufas e alimentava funcionários e cobaias. Com a imortalidade, ninguém mais precisava comer e ela perdeu o motivo de existir. Provou a humanidade líquida e não parou mais: bebeu memórias dos que morriam, depois dos que viviam.",
        meaning="Gula é tentar se encher com a vida dos outros porque a própria ficou vazia."),
    "durgan": dict(
        id="durgan", display_name="Durgan Vell", title="O Eco de Bronze", sin="Inveja", sin_meaning="Querer ser o outro",
        race="Anão", attribute="Raio", area="Forjas Ocas", scaling="Fé", suggested_order="4ª",
        memory_reward=1500, implemented=True, unique_mechanic="Copia os ataques que o jogador mais usou (contagem de ações → peso na escolha).",
        phases=["Fase 1 — O Engenheiro: chave-martelo elétrica, torretas e autômatos; placas acesas no chão indicam onde não pisar.",
                "Fase 2 — O Reflexo (metade da vida): armadura espelhada; usa os ataques que o jogador mais usou."],
        history="Irmão do Ferreiro do Teatro. Os dois forjaram as Âncoras que prendem as ilhas ao núcleo, mas só o irmão era visto. Nas forjas, Durgan construiu autômatos com o rosto do irmão — depois com o rosto de qualquer um. No fim, não sobrou um rosto que fosse dele.",
        meaning="Inveja é querer ser o outro até não sobrar você."),
    "rachel": dict(
        id="rachel", display_name="Rachel Azheryon Caelis", title="O Orgulho do Céu", sin="Orgulho", sin_meaning="Domínio",
        race="Dragão ígneo", attribute="Fogo", area="Montanha Carbonizada (Ninho dos Dragões)", scaling="Magia",
        suggested_order="5ª", memory_reward=1800, implemented=True,
        unique_mechanic="Arena que desmorona aos poucos, encolhendo o espaço seguro; rugidos derrubam estruturas.",
        phases=["Fase única — Domínio: hálito de fogo massivo, golpes de cauda que quebram o chão, rugidos que desestabilizam, arena desmoronando."],
        history="No continente de origem, os outros dragões a ignoravam. Ao encontrar Alexandria não viu beleza, viu posse. Queimou cidades, começando pela de Aldir, e fez seu ninho no topo da montanha. Dorme sobre as ruínas do mundo.",
        meaning="Orgulho é domínio sem arrependimento."),
    "cassian": dict(
        id="cassian", display_name="Cassian Virel", title="O Arconte do Zero", sin="Ganância", sin_meaning="Possessão",
        race="Humano", attribute="Magia / Gelo", area="Domínio Congelado", scaling="Magia", suggested_order="6ª",
        memory_reward=2000, implemented=True,
        unique_mechanic="Rouba estamina e congela partes da arena; o chão do Domínio escorrega.",
        phases=["Fase 1 — O Arquimago: magias de gelo e controle de espaço.",
                "Fase 2 — O Colecionador (metade da vida): congela metade da arena (quem fica vira bloco de gelo), invoca Estátuas Vivas e rouba estamina com um raio."],
        history="Arquimago do Projeto Alexandria. Enquanto outros buscavam transcendência, queria preservar o conhecimento. Preservar virou possuir: congelou bibliotecas, memórias raras e pessoas importantes. Queria ser o único dono do futuro.",
        meaning="Ganância é querer tudo, até o tempo."),
    "governanta": dict(
        id="governanta", display_name="A Governanta", title="A Que Conta Presenças", sin="Prólogo",
        sin_meaning="Um cuidado que virou prisão", race="Humana", attribute="—",
        area="Complexo das Cápsulas (prólogo)", scaling="—", suggested_order="Prólogo", memory_reward=250,
        implemented=True,
        unique_mechanic="Só luta se o jogador feriu alguma criança (Game.criancas_feridas). Sem nenhuma, ela só observa e deixa passar. Grito em anel, abraço que prende e, na fase 2, os ecos das crianças.",
        phases=["Fase 1 — A Que Ainda Cuida: molho de chaves, abraço em linha reta e o grito em anel.",
                "Fase 2 — A Conta Que Não Fecha (metade da vida): o coque se desfaz; grito duplo e os ecos das crianças correndo para você."],
        history="Cuidava das crianças do complexo. O tempo passou sem aviso e ela descobriu que ali ninguém podia morrer: as crianças se matavam repetidamente e regrediam, até restarem só ecos e uma mesa vazia. Ela ainda conta presenças que já não existem.",
        meaning="O grito dela não era de raiva; era de falha."),
    "sargento": dict(
        id="sargento", display_name="Sargento Sem Pelotão", title="Mini-chefe da Cidade Estilhaçada", sin="Mini-chefe",
        sin_meaning="Ira", race="Humano", attribute="—", area="Cidade Estilhaçada", scaling="—",
        suggested_order="1º mini-chefe da Cidade", memory_reward=300, implemented=True,
        unique_mechanic="Apita e chama reforços a cada 25% de vida perdida. Se ele cair, os reforços perdem a ordem e desabam.",
        phases=["Sabre rápido e estocada de oficial; apita (para tudo e avisa) e chama dois Soldados Remendados."],
        history="O último oficial de um pelotão que já não existe. Ainda dá ordens — e alguém ainda obedece.",
        meaning="Ensina a eliminar quem comanda antes do grupo."),
    "couraca": dict(
        id="couraca", display_name="A Couraça Andante", title="Mini-chefe da Cidade Estilhaçada", sin="Mini-chefe",
        sin_meaning="Ira", race="Humano", attribute="—", area="Cidade Estilhaçada", scaling="—",
        suggested_order="2º mini-chefe da Cidade", memory_reward=450, implemented=True,
        unique_mechanic="Soldado fundido a uma armadura pesada: só leva dano real pelas costas. Vira devagar; se você ficar atrás dele, gira.",
        phases=["Clavada lenta e pesada (prepara para o Aldir) e o Giro em 360° contra quem cola nas costas."],
        history="Um soldado que vestiu a armadura para uma última missão e nunca mais conseguiu tirá-la.",
        meaning="Prepara o jogador para os golpes lentos e pesados de Aldir."),
    "vigia": dict(
        id="vigia", display_name="O Vigia que Dormiu", title="Mini-chefe do Bosque do Sono Eterno", sin="Mini-chefe",
        sin_meaning="Preguiça", race="Guardião", attribute="—", area="Bosque do Sono Eterno", scaling="—",
        suggested_order="1º mini-chefe do Bosque", memory_reward=500, implemented=True,
        unique_mechanic="Dorme no caminho. Dá para passar escondido (sem barulho) ou acordá-lo e lutar — como na escolha da Governanta.",
        phases=["Martelada (círculo), varredura (arco) e o bocejo: um anel de sono que só o dash atravessa."],
        history="Guardava a entrada do bosque. Nyssa lhe disse que podia descansar um pouco. Faz décadas.",
        meaning="Lutar dá recompensa; passar em silêncio dá outra conversa com Nyssa."),
    "mae_esporos": dict(
        id="mae_esporos", display_name="A Mãe dos Esporos", title="Mini-chefe do Bosque do Sono Eterno", sin="Mini-chefe",
        sin_meaning="Preguiça", race="Planta", attribute="Sono", area="Bosque do Sono Eterno", scaling="—",
        suggested_order="2º mini-chefe do Bosque", memory_reward=550, implemented=True,
        unique_mechanic="Planta enorme cercada de Flores de Pólen. Ensina a Barra de Sonolência antes de Nyssa: quem dorme perto dela leva o cipó pesado.",
        phases=["Cipó (linha que trava), chuva de esporos e o florescer: um anel de sono enorme. Faz brotar flores."],
        history="Foi plantada para dar sono às cobaias que não conseguiam dormir. Ainda acha que está ajudando.",
        meaning="Atacar espanta o sono: a luta obriga o jogador a ser agressivo."),
    "banqueteiro": dict(
        id="banqueteiro", display_name="O Banqueteiro", title="Mini-chefe das Raízes da Fome", sin="Mini-chefe",
        sin_meaning="Gula", race="Humano", attribute="Sangue", area="Raízes da Fome", scaling="—",
        suggested_order="1º mini-chefe das Raízes", memory_reward=600, implemented=True,
        unique_mechanic="Serve 'pratos' de lacaios; se você demora, ele come os próprios lacaios e se cura. Mate a fonte de cura primeiro.",
        phases=["Cutelo (arco curto, pesado), concha (arco largo, empurra), servir (abre a cloche: larvas ou um Inchado) e comer um lacaio para se curar."],
        history="Cozinheiro do projeto. Servia Mabel muito antes de ela parar de comer comida.",
        meaning="Ensina a matar a fonte de cura primeiro — a lição que Mabel cobra na fase 2."),
    "ninhada": dict(
        id="ninhada", display_name="A Ninhada", title="Mini-chefe das Raízes da Fome", sin="Mini-chefe",
        sin_meaning="Gula", race="Larvas", attribute="Sangue", area="Raízes da Fome", scaling="—",
        suggested_order="2º mini-chefe das Raízes", memory_reward=650, implemented=True,
        unique_mechanic="Um amontoado de Larvas que se divide ao levar dano. Engole quem chega perto: toque rápido no Ataque para escapar.",
        phases=["Rola por cima (linha), engole (círculo: o agarrão) e solta larvas a cada pedaço de vida perdido."],
        history="Restos do que Mabel não terminou de comer, juntos num monte que ainda tem fome.",
        meaning="Testa controle de grupo e o agarrão antes de Mabel."),
    "prototipo": dict(
        id="prototipo", display_name="O Protótipo", title="Mini-chefe das Forjas Ocas", sin="Mini-chefe",
        sin_meaning="Inveja", race="Autômato", attribute="Raio", area="Forjas Ocas", scaling="—",
        suggested_order="1º mini-chefe das Forjas", memory_reward=650, implemented=True,
        unique_mechanic="Um autômato com o formato do jogador, inacabado. Usa só o ataque básico do jogador (e o dash para chegar perto).",
        phases=["Sequências de 1 a 3 cortes leves com o mesmo avanço do herói; dash para encurtar; recuperação depois do combo."],
        history="O primeiro rosto de alguém que passou pelas forjas. Durgan não terminou: faltavam peças. Faltava alguém dentro.",
        meaning="O primeiro sinal de que Durgan copia."),
    "guardiao_ancora": dict(
        id="guardiao_ancora", display_name="O Guardião da Âncora", title="Mini-chefe das Forjas Ocas", sin="Mini-chefe",
        sin_meaning="Inveja", race="Máquina", attribute="Raio", area="Forjas Ocas", scaling="—",
        suggested_order="2º mini-chefe das Forjas", memory_reward=700, implemented=True,
        unique_mechanic="Máquina enorme presa a uma corrente da ilha. A carcaça segura quase tudo; depois de dois ataques superaquece e expõe o núcleo.",
        phases=["Corrente (leque enorme), pilão (círculo + raio nas placas em volta), vapor (núcleo exposto)."],
        history="Os irmãos Vell forjaram as Âncoras que prendem as ilhas ao núcleo. Esta máquina guarda uma delas. Destruí-la faz a ilha tremer.",
        meaning="Abre o caminho até Durgan."),
    "capitao": dict(
        id="capitao", display_name="O Capitão Dragonoide", title="Mini-chefe da Montanha Carbonizada", sin="Mini-chefe",
        sin_meaning="Orgulho", race="Dragonoide", attribute="Fogo", area="Montanha Carbonizada", scaling="—",
        suggested_order="1º mini-chefe da Montanha", memory_reward=750, implemented=True,
        unique_mechanic="Alterna escudo enorme (quase nada passa pela frente) e lança-chamas (sem escudo, mas o chão pega fogo).",
        phases=["Escudo: anda devagar e dá escudadas; ataque pelas costas.", "Troca: um instante sem nada nas mãos — a janela.", "Chamas: varre um cone de fogo que deixa o chão queimando."],
        history="Os servos de Rachel eram lagartos das cavernas até ela os tocar. O Capitão foi o primeiro a se ajoelhar e o último a sair da porta do ninho.",
        meaning="Ensina a ler a troca de postura antes da Rachel."),
    "matriarca": dict(
        id="matriarca", display_name="A Matriarca Bestial", title="Mini-chefe da Montanha Carbonizada", sin="Mini-chefe",
        sin_meaning="Orgulho", race="Dragão bestial", attribute="Fogo", area="Montanha Carbonizada", scaling="—",
        suggested_order="2º mini-chefe da Montanha", memory_reward=800, implemented=True,
        unique_mechanic="Investidas em linha reta e pisoteios que abrem buracos no chão; quem bate na parede fica tonta.",
        phases=["Investida (linha no chão), mordida de perto, pisoteio (círculo) que abre buracos — a arena vai ficando menor."],
        history="Os dragões menores nunca voaram. Rachel os deixou viver no sopé para lembrar a si mesma o que ela não é.",
        meaning="Antecipa a arena que encolhe."),
    "curadora": dict(
        id="curadora", display_name="A Curadora de Vitrines", title="Mini-chefe do Domínio Congelado", sin="Mini-chefe",
        sin_meaning="Ganância", race="Humana", attribute="Gelo", area="Domínio Congelado", scaling="—",
        suggested_order="1º mini-chefe do Domínio", memory_reward=850, implemented=True,
        unique_mechanic="Prende o jogador em blocos de gelo (vitrines); quebrar o bloco exige toques rápidos. Preso, ela vem catalogar.",
        phases=["Vitrine (retângulo que congela), leque de estilhaços, bengala; a pancada pesada em quem ficou preso."],
        history="Cuidava do acervo do Projeto. Cassian pediu que guardasse as peças mais raras — e depois as pessoas mais raras.",
        meaning="Ensina a reagir ao controle de espaço."),
    "golem_arquivo": dict(
        id="golem_arquivo", display_name="O Golem do Arquivo", title="Mini-chefe do Domínio Congelado", sin="Mini-chefe",
        sin_meaning="Ganância", race="Construto", attribute="Gelo", area="Domínio Congelado", scaling="—",
        suggested_order="2º mini-chefe do Domínio", memory_reward=900, implemented=True,
        unique_mechanic="Feito de estantes congeladas; não cambaleia. Ao morrer, deixa um livro de lore sobre o Projeto Alexandria.",
        phases=["Pilão (círculo; o chão em volta congela), braço-estante em leque, leque de livros arremessados."],
        history="As estantes do Arquivo Central, congeladas de pé. Alguém lhes deu ordem de proteger os livros de todo mundo.",
        meaning="Guarda a porta de Cassian e a verdade do Projeto."),
    "cavaleiro": dict(
        id="cavaleiro", display_name="O Cavaleiro Desolado", title="Guardião do Núcleo", sin="—", sin_meaning="Proteção que virou prisão",
        race="O que restou do Cientista da Gravidade", attribute="Gravidade", area="O Núcleo", scaling="—",
        suggested_order="Final", memory_reward=0, implemented=True,
        unique_mechanic="Fica sempre entre você e a mulher do núcleo. Gravidade: puxa, empurra e faz chover pedra. Ao vencê-lo, a escolha: Proteger (Continuidade) ou Destruir (Ruptura).",
        phases=["Fase 1 — O Guardião: espadão em três tempos, guarda que apara de frente e a gravidade que puxa você para perto.",
                "Fase 2 — A Promessa (metade da vida): pedras caem do alto, um anel que empurra e, ajoelhado, ele renova o elo com ela — fique no caminho da luz para cortar a cura."],
        history="Não é um vilão clássico. Parece frustrado por não ter cumprido seu objetivo, mas o objetivo nunca foi conquista: foi proteção. Enquanto a mulher ligada ao núcleo existir, a ilha flutua e o ciclo continua.",
        meaning="Algumas coisas sobrevivem, mas nunca vivem. / Libertar algo pode ser o mesmo que destruí-lo."),
}


def sprite_frames(texture: str, frame_w: int, frame_h: int, count: int, anims: dict) -> str:
    """anims = {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 8.0)}"""
    lines = [f'[gd_resource type="SpriteFrames" load_steps={count + 2} format=3]', "",
             f'[ext_resource type="Texture2D" path="{texture}" id="1_tex"]', ""]
    for i in range(count):
        lines += [f'[sub_resource type="AtlasTexture" id="AtlasTexture_{i}"]', 'atlas = ExtResource("1_tex")',
                  f"region = Rect2({i * frame_w}, 0, {frame_w}, {frame_h})", ""]
    blocks = []
    for name, (frames, speed) in anims.items():
        frame_list = ", ".join('{\n"duration": 1.0,\n"texture": SubResource("AtlasTexture_%d")\n}' % f for f in frames)
        blocks.append('{\n"frames": [%s],\n"loop": true,\n"name": &"%s",\n"speed": %s\n}' % (frame_list, name, repr(float(speed))))
    lines += ["[resource]", "animations = [%s]" % ", ".join(blocks)]
    return "\n".join(lines) + "\n"



# --- Itens (inventario) -------------------------------------------------------------
# kind: 0 = Equipamento, 1 = Consumivel, 2 = Material, 3 = Lembranca (ItemData.Kind)
ITEMS = {
    "espada": dict(display_name="Espada de Cobaia", kind=0, max_stack=1, icon="res://assets/items/espada.png",
        description="Estava ao lado da sua cápsula. Ninguém deixa uma arma ao lado de quem dorme — a não ser que espere que ele acorde lutando.\nO Ferreiro do Teatro sabe deixá-la mais afiada."),
    "escudo_remendado": dict(display_name="Escudo Remendado", kind=0, max_stack=1, icon="res://assets/items/escudo_remendado.png",
        description="Tampa de aço com o brasão raspado a faca. Os soldados da Cidade carregam iguais; este é o único que ninguém veio buscar.\nMão esquerda: segure a defesa para erguê-lo. Segura golpes pela frente, mas cada golpe custa estamina — sem estamina, a guarda quebra. O grito e as ondas no chão passam por cima dele."),
    "frasco_vida": dict(display_name="Frasco de Vida", kind=1, max_stack=99, icon="res://assets/ui/icon_heal.png",
        description="Um gole vermelho que fecha feridas. Enche de novo em toda Câmara de descanso.\nO Orbe Branco sabe fazer mais deles."),
    "frasco_sanidade": dict(display_name="Frasco de Sanidade", kind=1, max_stack=99, icon="res://assets/ui/icon_sanity.png",
        description="Humanidade líquida. Jogada no rosto, a pele absorve e a visão volta.\nDe quem era?"),
    "sucata_temperada": dict(display_name="Sucata Temperada", kind=2, max_stack=99, icon="res://assets/items/sucata_temperada.png",
        description="Aço de armas consertadas tantas vezes que já não lembram a forma original.\nO Ferreiro sabe o que fazer com isso."),
    "fragmento_turvo": dict(display_name="Fragmento Turvo", kind=2, max_stack=99, icon="res://assets/items/fragmento_turvo.png",
        description="Caco de um frasco, opaco de lembranças que não são suas.\nSó o Orbe Branco consegue clarear — e um caco limpo vira mais um Frasco de Vida."),
    "apito_sargento": dict(display_name="Apito do Sargento", kind=3, max_stack=1, icon="res://assets/items/apito_sargento.png",
        description="Ainda tem gosto de ordens. Você sopra e ninguém vem.\nPela primeira vez em décadas, o pelotão está dispensado."),
    "lembranca_governanta": dict(display_name="Lembrança: Uma Mesa Vazia", kind=3, max_stack=1, icon="res://assets/items/lembranca_governanta.png",
        description="Crianças brincando. A morte retirada daquele lugar. Um cuidado que virou prisão.\nO grito dela não era de raiva. Era de falha."),
    "lembranca_aldir": dict(display_name="Lembrança: Ira · Impotência", kind=3, max_stack=1, icon="res://assets/items/lembranca_aldir.png",
        description="Um soldado aposentado que não ouviu a família. Quando entendeu o perigo, a cidade já queimava.\nIra é impotência transformada em violência: não conseguiu proteger ninguém, então decidiu destruir tudo."),
    "lembranca_nyssa": dict(display_name="Lembrança: Preguiça · Desistência", kind=3, max_stack=1, icon="res://assets/items/lembranca_nyssa.png",
        description="Duas irmãs cuidavam das cápsulas: uma fazia dormir, a outra acordava. Uma delas viu o que cada morte tirava das pessoas e parou de acordar alguém.\nPreguiça não é cansaço do corpo; é desistir de mudar porque mudar dói."),
    "lembranca_mabel": dict(display_name="Lembrança: Gula · Vazio", kind=3, max_stack=1, icon="res://assets/items/lembranca_mabel.png",
        description="Ela alimentava todo mundo. Quando ninguém mais precisou comer, provou a humanidade líquida e sentiu o primeiro beijo de um guarda, o aniversário de uma criança. Não parou mais.\nGula é tentar se encher com a vida dos outros porque a própria ficou vazia."),
    "lembranca_durgan": dict(display_name="Lembrança: Inveja · Querer ser o outro", kind=3, max_stack=1, icon="res://assets/items/lembranca_durgan.png",
        description="Dois irmãos forjaram as Âncoras. O nome de um ficou nas placas. O outro fazia igual, às vezes melhor, e ninguém via — então passou a copiar todo mundo.\nInveja é querer ser o outro até não sobrar você."),
    "lembranca_rachel": dict(display_name="Lembrança: Orgulho · Domínio", kind=3, max_stack=1, icon="res://assets/items/lembranca_rachel.png",
        description="No continente de onde veio, os outros dragões não olhavam para ela. Aqui, todo mundo olhou: de baixo, enquanto a cidade queimava.\nOrgulho é domínio sem arrependimento."),
    "lembranca_cassian": dict(display_name="Lembrança: Ganância · Possessão", kind=3, max_stack=1, icon="res://assets/items/lembranca_cassian.png",
        description="Ele guardava tudo para que nada se perdesse: livros, vozes, rostos. Um dia percebeu que só ele podia abrir as vitrines — e gostou.\nGanância é querer tudo, até o tempo."),
    "anel_do_guarda": dict(display_name="Anel do Guarda", kind=3, max_stack=1, icon="res://assets/items/anel_do_guarda.png",
        description="Ele usou até o fim sem saber de quem era a outra metade. Por dentro, gravado quase apagado: “no posto”.\nAlguém, em algum lugar deste teatro, tem a outra."),
    "lembranca_cavaleiro": dict(display_name="Lembrança: O Posto Vazio", kind=3, max_stack=1, icon="res://assets/items/lembranca_cavaleiro.png",
        description="Ele protegeu o Núcleo até esquecer de quem. A armadura continuou de pé depois que ele foi embora.\nNão é um pecado. É o que sobra quando todos os outros terminam."),
    "lembranca_helena": dict(display_name="Lembrança: Luxúria · Apego", kind=3, max_stack=1, icon="res://assets/items/lembranca_helena.png",
        description="Ela e o marido eram os melhores agentes. Na invasão, um deles saiu do posto.\nLuxúria aqui é apego: não aceitar a perda."),
}


# --- Parry (v0.21) -----------------------------------------------------------------
# Quem NAO da para aparar: agarroes (unblockable), golpes de gigantes e chefes
# pesados demais (seria absurdo desviar o martelo do Aldir com um escudo de tampa)
# e os golpes do proprio heroi (o Durgan copia; os golpes das armas sao do heroi).
NOT_PARRYABLE_PREFIXES = ("aldir_", "couraca_", "mabel_", "rachel_", "golem_", "vigia_", "matriarca_",
                          "automato_", "estatua_", "player_", "arma_")
NOT_PARRYABLE = {"bestial_investida", "ninhada_investida", "banqueteiro_cutelo", "capitao_escudada",
                 "durgan_martelada", "durgan_copia_forte", "cavaleiro_corte_3", "minerador_3"}


def is_parryable(name: str, props: dict) -> bool:
    if props.get("unblockable"):
        return False
    return name not in NOT_PARRYABLE and not name.startswith(NOT_PARRYABLE_PREFIXES)


# --- Armas (v0.20) ------------------------------------------------------------------
# Cada arma e um WeaponData (que herda de ItemData: e item E arma).
# light/heavy vazios = usa os golpes do heroi (player_light_1..3 / player_heavy).
WEAPONS = {
    "espada": dict(display_name="Espada de Cobaia", weapon_class="Espada", scaling={"forca": "C", "destreza": "C"},
        icon="espada", hand="player_sword", special="arma_giro_cobaia", memories=400, sucata=2,
        description=ITEMS["espada"]["description"]),
    "lamina_desolada": dict(display_name="Lâmina Desolada", weapon_class="Espada", scaling={"destreza": "A"},
        damage_scale=1.05, speed_scale=0.85, stamina_scale=0.9, special="arma_estocada_desolada",
        skill="estocada_desolada", skill_name="Estocada Desolada",
        skill_text="o especial é uma estocada que atravessa a distância. Se acertar um inimigo, devolve fôlego.",
        boss="helena", memory="lembranca_helena", memories=1500, sucata=3,
        description="O sabre de quem não saiu do posto. Leve demais para ser de guerra; afiado demais para ser de enfeite.\nNas mãos certas, nunca para."),
    "pilar_estilhacada": dict(display_name="Pilar da Estilhaçada", weapon_class="Martelo", scaling={"forca": "S"},
        damage_scale=1.3, speed_scale=1.3, stamina_scale=1.25, special="arma_pilar_impacto",
        skill="onda_estilhacada", skill_name="Onda Estilhaçada",
        skill_text="o especial racha o chão: a onda derruba a guarda de todos em volta e quebra coberturas.",
        boss="aldir", memory="lembranca_aldir", memories=1500, sucata=3,
        description="Um pedaço da Cidade que ele mesmo derrubou, preso num cabo.\nA raiva dele não queria vencer. Queria que nada ficasse de pé."),
    "presa_caelis": dict(display_name="Presa de Caelis", weapon_class="Espada Grande", scaling={"forca": "B", "magia": "C"},
        damage_scale=1.2, speed_scale=1.2, stamina_scale=1.15, special="arma_presa_corte",
        skill="rastro_caelis", skill_name="Rastro de Caelis",
        skill_text="o especial deixa fogo no chão por 3 s. Custa estamina extra (é a magia que o jogo cobra).",
        boss="rachel", memory="lembranca_rachel", memories=5000, sucata=6,
        description="Uma escama do peito dela, afiada até virar lâmina. Ainda está quente.\nO orgulho não se apaga; só espera alguém pisar perto."),
    "fuso_arconte": dict(display_name="Fuso do Arconte", weapon_class="Lança", scaling={"magia": "A", "destreza": "C"},
        damage_scale=1.0, speed_scale=1.0, stamina_scale=1.0, special="arma_fuso_estocada",
        skill="dreno_arconte", skill_name="Dreno do Arconte",
        skill_text="cada golpe rouba fôlego do inimigo para você e atrasa o próximo ataque dele.",
        boss="cassian", memory="lembranca_cassian", memories=6000, sucata=6,
        description="A haste com que ele girava as vitrines. Tudo que ela toca vira coleção.\nGanância é tirar do outro até o tempo de reagir."),
    "replicador_bronze": dict(display_name="Replicador de Bronze", weapon_class="Besta", scaling={"fe": "B", "destreza": "B"},
        damage_scale=1.0, speed_scale=1.0, stamina_scale=1.0, light=["arma_virote"], heavy="arma_virote_forte", special="arma_virote_carregado",
        ranged=True, skill="virote_replicante", skill_name="Virote Replicante",
        skill_text="o virote elétrico salta para o inimigo mais perto (o especial, carregado, salta duas vezes).",
        boss="durgan", memory="lembranca_durgan", memories=4000, sucata=5,
        description="Ele não inventou esta besta. Copiou a do irmão, peça por peça, e ela saiu melhor.\nInveja também é uma forma de aprender."),
    "presas_voragem": dict(display_name="Presas da Vorágine", weapon_class="Adagas", scaling={"sorte": "A", "destreza": "B"},
        damage_scale=0.72, speed_scale=0.7, stamina_scale=0.75, special="arma_frenesi_voragem",
        skill="fome_voragem", skill_name="Fome da Vorágine",
        skill_text="os golpes fazem sangrar (a barra enche e estoura; o especial, um avanço em frenesi, enche muito) e cada acerto devolve um pouco de vida: 2 + Sorte × 0,2.",
        boss="mabel", memory="lembranca_mabel", memories=3000, sucata=4,
        description="Dois talheres da cozinha dela, gastos de tanto raspar o fundo da panela.\nA fome não acaba quando o prato enche."),
    "arco_sono": dict(display_name="Arco do Sono Eterno", weapon_class="Arco", scaling={"fe": "S"},
        damage_scale=1.0, speed_scale=1.0, stamina_scale=1.0, light=["arma_flecha"], heavy="arma_flecha_forte", special="arma_flecha_polen",
        ranged=True, skill="polen_sono", skill_name="Pólen do Sono",
        skill_text="a flecha especial abre uma nuvem de pólen: quem está dentro anda e ataca na metade da velocidade.",
        boss="nyssa", memory="lembranca_nyssa", memories=2500, sucata=4,
        description="Um galho da estufa que nunca acordou. As flores ainda abrem quando alguém boceja.\nPreguiça é fazer o mundo ir mais devagar para não ter que alcançá-lo."),
    "ancora_gravidade": dict(display_name="Âncora da Gravidade", weapon_class="Machado", scaling={"forca": "A", "fe": "A"},
        damage_scale=1.25, speed_scale=1.25, stamina_scale=1.2, special="arma_ancora_fincada",
        skill="vortice_ancora", skill_name="Vórtice da Âncora",
        skill_text="o especial finca o machado: o chão puxa os inimigos para perto e explode. Chefes e gigantes não saem do lugar.",
        boss="cavaleiro", memory="lembranca_cavaleiro", memories=0, sucata=0,
        description="O machado que segurava a ilha no lugar. Pesa como uma promessa.\nQuem o ergue entende por que ele nunca saiu do posto."),
}


def weapon_resource(weapon_id: str, w: dict) -> str:
    """WeaponData (.tres) com as referencias de icone, sprite e golpes."""
    ext = [
        ("Script", "res://scripts/items/weapon_data.gd"),
        ("Texture2D", f"res://assets/items/{w.get('icon', weapon_id)}.png"),
        ("Texture2D", f"res://assets/sprites/{w.get('hand', 'arma_' + weapon_id)}.png"),
    ]
    light = w.get("light", [])
    if light:  # Array tipado (Array[AttackData]) precisa do script do AttackData
        ext.append(("Script", "res://scripts/combat/attack_data.gd"))
    for name in light:
        ext.append(("Resource", f"res://data/attacks/{name}.tres"))
    if w.get("heavy"):
        ext.append(("Resource", f"res://data/attacks/{w['heavy']}.tres"))
    if w.get("special"):
        ext.append(("Resource", f"res://data/attacks/{w['special']}.tres"))
    lines = [f'[gd_resource type="Resource" script_class="WeaponData" load_steps={len(ext) + 1} format=3]', ""]
    for i, (kind, path) in enumerate(ext, start=1):
        lines.append(f'[ext_resource type="{kind}" path="{path}" id="{i}"]')
    lines += ["", "[resource]", 'script = ExtResource("1")',
              f"id = {gd_value(weapon_id)}",
              f"display_name = {gd_value(w['display_name'])}",
              f"description = {gd_value(w['description'])}",
              "kind = 0", 'icon = ExtResource("2")', "max_stack = 2",  # 2: uma em cada mao
              f"weapon_class = {gd_value(w['weapon_class'])}",
              "scaling = {%s}" % ", ".join(f"{gd_value(k)}: {gd_value(v)}" for k, v in w["scaling"].items())]
    first_attack = 5 if light else 4
    if light:
        refs = ", ".join(f'ExtResource("{first_attack + i}")' for i in range(len(light)))
        lines.append('light_combo = Array[ExtResource("4")]([%s])' % refs)
    next_id = first_attack + len(light)
    if w.get("heavy"):
        lines.append(f'heavy_attack = ExtResource("{next_id}")')
        next_id += 1
    if w.get("special"):
        lines.append(f'special_attack = ExtResource("{next_id}")')
    for key in ("damage_scale", "speed_scale", "stamina_scale"):
        if key in w:
            lines.append(f"{key} = {gd_value(float(w[key]))}")
    for key, prop in (("skill", "skill"), ("skill_name", "skill_name"), ("skill_text", "skill_text"),
                      ("boss", "boss_id"), ("memory", "memory_item")):
        if key in w:
            lines.append(f"{prop} = {gd_value(w[key])}")
    if w.get("ranged"):
        lines.append("ranged = true")
    lines.append('hand_texture = ExtResource("3")')
    if "memories" in w:
        lines.append(f"forge_memories = {w['memories']}")
        lines.append(f"forge_sucata = {w['sucata']}")
    return "\n".join(lines) + "\n"


def item_resource(item_id: str, props: dict) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="ItemData" load_steps=3 format=3]',
        "",
        '[ext_resource type="Script" path="res://scripts/items/item_data.gd" id="1_script"]',
        f'[ext_resource type="Texture2D" path="{props["icon"]}" id="2_icon"]',
        "",
        "[resource]",
        'script = ExtResource("1_script")',
        f"id = {gd_value(item_id)}",
        f"display_name = {gd_value(props['display_name'])}",
        f"description = {gd_value(props['description'])}",
        f"kind = {props['kind']}",
        'icon = ExtResource("2_icon")',
        f"max_stack = {props['max_stack']}",
    ]
    return "\n".join(lines) + "\n"


# --- Armaduras (v0.25) ----------------------------------------------------------------
# 7 conjuntos x 5 pecas. Os NUMEROS dos efeitos moram em scripts/items/armor_sets.gd
# (uma tabela so); aqui ficam nome, lore e icone de cada peca.
ARMOR_SLOTS = [("capacete", "Capacete"), ("peitoral", "Peitoral"), ("luvas", "Luvas"), ("calca", "Calça"), ("botas", "Botas")]
ARMOR_SETS = {
    "vigilia": ("da Vigília", "Costurado para quem ficava acordado vigiando as cápsulas. O tecido ainda guarda o calor de noites inteiras sem dormir.",
                "Escondido atrás da cortina do palco do Teatro."),
    "detentor": ("do Detentor", "Aço da guarda pessoal do Aldir. Cada amassado é uma ordem que ele deu gritando.",
                 "Largado na grama, no canto da Cidade."),
    "sono": ("do Sono Leve", "As irmãs vestiam isto para velar o sono dos outros. Quem usa descansa entre um golpe e outro.",
             "Num recanto escondido, no alto do Bosque."),
    "banquete": ("do Banquete", "Avental, luvas e botas de quem servia a mesa da Mabel. Os bolsos nunca estão vazios.",
                 "Na ponta da ilha, embaixo das Raízes."),
    "eco": ("do Eco", "Forjada pelos dois irmãos a quatro mãos. Os golpes de quem a veste ecoam um pouco mais longe.",
            "No canto do salão grande das Forjas."),
    "caelis": ("de Caelis", "Escamas que a dragoa largou ao trocar de pele. Leves como um voo curto.",
               "No fim da ala esquerda da Montanha."),
    "arconte": ("do Arconte", "Bordado com fios de vitrine. Tudo o que toca, quer guardar — inclusive as memórias dos outros.",
                "No corredor gelado sem saída do Domínio."),
}
ARMOR = {}
for _set, (_suffix, _lore, _where) in ARMOR_SETS.items():
    for _slot, _slot_name in ARMOR_SLOTS:
        ARMOR[f"{_slot}_{_set}"] = dict(display_name=f"{_slot_name} {_suffix}", slot=_slot, set_id=_set,
            icon=f"res://assets/items/armadura_{_set}_{_slot}.png", description=_lore)


def armor_resource(item_id: str, a: dict) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="ArmorData" load_steps=3 format=3]',
        "",
        '[ext_resource type="Script" path="res://scripts/items/armor_data.gd" id="1_script"]',
        f'[ext_resource type="Texture2D" path="{a["icon"]}" id="2_icon"]',
        "",
        "[resource]",
        'script = ExtResource("1_script")',
        f"id = {gd_value(item_id)}",
        f"display_name = {gd_value(a['display_name'])}",
        f"description = {gd_value(a['description'])}",
        "kind = 4",
        'icon = ExtResource("2_icon")',
        "max_stack = 1",
        f"slot = {gd_value(a['slot'])}",
        f"set_id = {gd_value(a['set_id'])}",
    ]
    return "\n".join(lines) + "\n"


def main() -> None:
    print("Golpes")
    for name, props in ATTACKS.items():
        merged = {"display_name": props.get("display_name", name)}
        merged.update({k: props.get(k, v) for k, v in ATTACK_DEFAULTS.items()})
        if props.get("unblockable"):
            merged["unblockable"] = True  # só escreve quando é verdade (o padrão é false)
        if not is_parryable(name, props):
            merged["parryable"] = False  # idem: o padrão é aparável
        write(f"data/attacks/{name}.tres", resource("res://scripts/combat/attack_data.gd", "AttackData", merged))
    print("Chefes")
    for name, props in BOSSES.items():
        write(f"data/bosses/{name}.tres", resource("res://scripts/bosses/boss_data.gd", "BossData", props))
    print("Itens")
    for item_id, props in ITEMS.items():
        if item_id in WEAPONS:
            continue  # armas sao escritas abaixo (WeaponData)
        write(f"data/items/{item_id}.tres", item_resource(item_id, props))
    print("Armaduras")
    for armor_id, props in ARMOR.items():
        write(f"data/items/{armor_id}.tres", armor_resource(armor_id, props))
    print("Armas")
    for weapon_id, props in WEAPONS.items():
        write(f"data/items/{weapon_id}.tres", weapon_resource(weapon_id, props))
    print("SpriteFrames")
    walk = {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 8.0)}
    write("assets/sprites/player_frames.tres", sprite_frames("res://assets/sprites/player.png", 24, 24, 4, walk))
    write("assets/sprites/soldier_frames.tres", sprite_frames("res://assets/sprites/soldier.png", 24, 24, 4, walk))
    write("assets/sprites/helena_frames.tres", sprite_frames("res://assets/sprites/helena_body.png", 32, 32, 4, walk))
    heavy_walk = {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 6.0)}
    write("assets/sprites/aldir_frames.tres", sprite_frames("res://assets/sprites/aldir_body.png", 40, 40, 4, heavy_walk))
    quick_walk = {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 10.0)}
    for name in ("crianca_a", "crianca_b", "adolescente"):
        write(f"assets/sprites/{name}_frames.tres", sprite_frames(f"res://assets/sprites/{name}.png", 24, 24, 4, quick_walk))
    write("assets/sprites/cao_frames.tres", sprite_frames("res://assets/sprites/cao.png", 24, 24, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 12.0), "morder": ([4], 1.0)}))
    write("assets/sprites/atirador_frames.tres", sprite_frames("res://assets/sprites/atirador.png", 24, 24, 4, walk))
    write("assets/sprites/sargento_frames.tres", sprite_frames("res://assets/sprites/sargento.png", 24, 24, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 8.0), "apito": ([4], 1.0)}))
    write("assets/sprites/couraca_frames.tres", sprite_frames("res://assets/sprites/couraca.png", 32, 32, 4,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 4.0)}))
    write("assets/sprites/civil_frames.tres", sprite_frames("res://assets/sprites/civil.png", 24, 24, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 5.0), "agarrar": ([4], 1.0)}))
    write("assets/sprites/sonambulo_frames.tres", sprite_frames("res://assets/sprites/sonambulo.png", 24, 24, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 4.0), "bracos": ([4], 1.0)}))
    write("assets/sprites/flor_polen_frames.tres", sprite_frames("res://assets/sprites/flor_polen.png", 24, 24, 3,
          {"idle": ([0, 1, 2], 0.0)}))
    write("assets/sprites/cervo_frames.tres", sprite_frames("res://assets/sprites/cervo.png", 32, 32, 6,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 9.0), "investida": ([4], 1.0), "salto": ([5], 1.0)}))
    write("assets/sprites/fada_murcha_frames.tres", sprite_frames("res://assets/sprites/fada_murcha.png", 16, 16, 2,
          {"idle": ([0, 1], 6.0), "walk": ([0, 1], 8.0)}))
    write("assets/sprites/vigia_frames.tres", sprite_frames("res://assets/sprites/vigia.png", 48, 48, 5,
          {"dormindo": ([0], 1.0), "idle": ([1], 5.0), "walk": ([1, 2, 1, 3], 4.0), "golpe": ([4], 1.0)}))
    write("assets/sprites/nyssa_frames.tres", sprite_frames("res://assets/sprites/nyssa.png", 32, 32, 5,
          {"deitada": ([0, 1], 1.2), "sentada": ([2, 3], 3.0), "conjura": ([4], 1.0)}))
    write("assets/sprites/mae_esporos_frames.tres", sprite_frames("res://assets/sprites/mae_esporos.png", 48, 48, 3,
          {"idle": ([0, 1, 2], 0.0)}))
    write("assets/sprites/boca_de_raiz_frames.tres", sprite_frames("res://assets/sprites/boca_de_raiz.png", 24, 24, 5,
          {"idle": ([0], 1.0), "oculta": ([0], 1.0), "inchando": ([1], 1.0), "aberta": ([2], 1.0),
           "mastiga": ([3, 2], 6.0), "afunda": ([4], 1.0)}))
    write("assets/sprites/inchado_frames.tres", sprite_frames("res://assets/sprites/inchado.png", 24, 24, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 5.0), "incha": ([4], 1.0)}))
    write("assets/sprites/colhedor_frames.tres", sprite_frames("res://assets/sprites/colhedor.png", 32, 32, 6,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 6.0), "prepara": ([4], 1.0), "ceifa": ([5], 1.0)}))
    write("assets/sprites/larva_seiva_frames.tres", sprite_frames("res://assets/sprites/larva_seiva.png", 16, 16, 3,
          {"idle": ([0, 1], 3.0), "walk": ([0, 1], 9.0), "morde": ([2], 1.0)}))
    write("assets/sprites/banqueteiro_frames.tres", sprite_frames("res://assets/sprites/banqueteiro.png", 48, 48, 7,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 5.0), "cutelo": ([4], 1.0), "serve": ([5], 1.0), "come": ([6], 1.0)}))
    write("assets/sprites/ninhada_frames.tres", sprite_frames("res://assets/sprites/ninhada.png", 48, 48, 3,
          {"idle": ([0, 1], 3.0), "walk": ([0, 1], 5.0), "ergue": ([2], 1.0)}))
    write("assets/sprites/mabel_frames.tres", sprite_frames("res://assets/sprites/mabel.png", 64, 64, 12,
          {"idle": ([0, 2], 1.5), "walk": ([1, 0, 3, 2], 4.0), "tapa_prepara": ([4], 1.0), "tapa": ([5], 1.0),
           "arremesso": ([6], 1.0), "agarrao": ([7], 1.0), "engole": ([8], 1.0), "idle2": ([9], 1.0),
           "walk2": ([9, 10], 3.0), "come": ([11], 1.0)}))
    write("assets/sprites/raiz_veia_frames.tres", sprite_frames("res://assets/sprites/raiz_veia.png", 24, 32, 2,
          {"idle": ([0, 1], 2.0)}))
    write("assets/sprites/automato_frames.tres", sprite_frames("res://assets/sprites/automato.png", 24, 24, 2,
          {"idle": ([0], 1.0), "walk": ([0], 1.0), "ergue": ([1], 1.0)}))
    write("assets/sprites/torreta_frames.tres", sprite_frames("res://assets/sprites/torreta.png", 16, 24, 2,
          {"idle": ([0], 1.0), "carrega": ([1, 0], 12.0)}))
    write("assets/sprites/minerador_frames.tres", sprite_frames("res://assets/sprites/minerador.png", 24, 24, 7,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 7.0), "ergue": ([4], 1.0), "ergue_alto": ([5], 1.0), "golpe": ([6], 1.0)}))
    write("assets/sprites/imitador_frames.tres", sprite_frames("res://assets/sprites/imitador.png", 24, 24, 4, walk))
    write("assets/sprites/prototipo_frames.tres", sprite_frames("res://assets/sprites/prototipo.png", 24, 24, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 9.0), "golpe": ([4], 1.0)}))
    write("assets/sprites/guardiao_ancora_frames.tres", sprite_frames("res://assets/sprites/guardiao_ancora.png", 64, 64, 4,
          {"idle": ([0], 1.0), "prepara": ([1], 1.0), "golpe": ([2], 1.0), "vapor": ([3], 1.0)}))
    write("assets/sprites/durgan_frames.tres", sprite_frames("res://assets/sprites/durgan.png", 32, 32, 10,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 7.0), "idle2": ([4], 5.0), "walk2": ([4, 5, 6, 7], 8.0),
           "bebe": ([8], 1.0), "guarda": ([9], 1.0)}))
    write("assets/sprites/dragonoide_atirador_frames.tres", sprite_frames("res://assets/sprites/dragonoide_atirador.png", 24, 24, 4,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 8.0)}))
    write("assets/sprites/dragao_bestial_frames.tres", sprite_frames("res://assets/sprites/dragao_bestial.png", 32, 24, 6,
          {"idle": ([0, 2], 2.0), "walk": ([0, 1, 2, 3], 8.0), "investida": ([4], 1.0), "morde": ([5], 1.0)}))
    write("assets/sprites/dragao_alado_frames.tres", sprite_frames("res://assets/sprites/dragao_alado.png", 32, 24, 4,
          {"voa": ([0, 1], 8.0), "mergulho": ([2], 1.0), "chao": ([3], 1.0)}))
    write("assets/sprites/brasa_viva_frames.tres", sprite_frames("res://assets/sprites/brasa_viva.png", 16, 16, 3,
          {"idle": ([0, 1, 2], 8.0), "walk": ([0, 1, 2], 12.0)}))
    write("assets/sprites/capitao_dragonoide_frames.tres", sprite_frames("res://assets/sprites/capitao_dragonoide.png", 32, 32, 5,
          {"escudo": ([0], 1.0), "escudo_anda": ([1, 0, 2, 0], 6.0), "troca": ([3], 1.0), "chamas": ([4], 1.0)}))
    write("assets/sprites/matriarca_bestial_frames.tres", sprite_frames("res://assets/sprites/matriarca_bestial.png", 64, 48, 5,
          {"idle": ([0], 1.0), "walk": ([0, 1], 4.0), "ergue": ([2], 1.0), "investida": ([3], 1.0), "morde": ([4], 1.0)}))
    write("assets/sprites/rachel_frames.tres", sprite_frames("res://assets/sprites/rachel.png", 96, 72, 8,
          {"dorme": ([0], 1.0), "idle": ([1], 1.0), "walk": ([1, 2], 3.0), "prepara": ([3], 1.0), "fogo": ([4], 1.0),
           "cauda": ([5], 1.0), "ruge": ([6], 1.0), "garra": ([7], 1.0)}))
    robe = {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 7.0)}
    write("assets/sprites/bibliotecario_gelo_frames.tres", sprite_frames("res://assets/sprites/bibliotecario_gelo.png", 24, 24, 4, robe))
    write("assets/sprites/aprendiz_arcano_frames.tres", sprite_frames("res://assets/sprites/aprendiz_arcano.png", 24, 24, 4, robe))
    write("assets/sprites/estatua_viva_frames.tres", sprite_frames("res://assets/sprites/estatua_viva.png", 24, 26, 4,
          {"idle": ([0], 1.0), "walk": ([1, 0, 2, 0], 8.0), "golpe": ([3], 1.0)}))
    write("assets/sprites/acaro_cristal_frames.tres", sprite_frames("res://assets/sprites/acaro_cristal.png", 12, 10, 3,
          {"idle": ([0, 1], 4.0), "walk": ([0, 1, 2], 14.0)}))
    write("assets/sprites/curadora_vitrines_frames.tres", sprite_frames("res://assets/sprites/curadora_vitrines.png", 32, 32, 5,
          {"idle": ([0], 5.0), "walk": ([0, 1, 0, 2], 6.0), "conjura": ([3], 1.0), "bengala": ([4], 1.0)}))
    write("assets/sprites/golem_arquivo_frames.tres", sprite_frames("res://assets/sprites/golem_arquivo.png", 48, 48, 5,
          {"idle": ([0], 1.0), "walk": ([0, 1], 3.0), "ergue": ([2], 1.0), "esmaga": ([3], 1.0), "varre": ([4], 1.0)}))
    write("assets/sprites/cassian_frames.tres", sprite_frames("res://assets/sprites/cassian.png", 32, 32, 7,
          {"idle": ([0], 5.0), "walk": ([0, 1, 0, 2], 6.0), "conjura": ([3], 1.0), "ergue": ([4], 1.0),
           "cajado": ([5], 1.0), "idle2": ([6], 5.0)}))
    write("assets/sprites/cavaleiro_frames.tres", sprite_frames("res://assets/sprites/cavaleiro.png", 40, 40, 8,
          {"idle": ([0], 5.0), "walk": ([0, 1, 0, 2], 5.0), "ergue": ([3], 1.0), "corte": ([4], 1.0),
           "guarda": ([5], 1.0), "atrai": ([6], 1.0), "ajoelha": ([7], 1.0)}))
    write("assets/sprites/guarda_frames.tres", sprite_frames("res://assets/sprites/guarda.png", 24, 24, 6,
          {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 8.0), "golpe": ([4], 1.0), "caido": ([5], 1.0)}))
    governess = {"idle": ([0], 5.0), "walk": ([0, 1, 2, 3], 7.0), "abraco": ([4], 1.0), "grito": ([5], 1.0)}
    write("assets/sprites/governanta_frames.tres", sprite_frames("res://assets/sprites/governanta_body.png", 32, 40, 6, governess))
    write("assets/sprites/governanta_solto_frames.tres", sprite_frames("res://assets/sprites/governanta_solto.png", 32, 40, 6, governess))


if __name__ == "__main__":
    main()

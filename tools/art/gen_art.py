"""Gera TODA a arte do jogo em assets/.

Uso (na raiz do projeto):  python3 tools/art/gen_art.py
Requer Pillow (pip install pillow). Rode de novo sempre que editar uma grade.
"""
from __future__ import annotations

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))

import aldir as AL  # noqa: E402
import characters as C  # noqa: E402
import palette as P  # noqa: E402
import prologo as PG  # noqa: E402
import cidade as CI  # noqa: E402
import itens as IT  # noqa: E402
import bosque as BQ  # noqa: E402
import raizes as RZ  # noqa: E402
import forjas as FJ  # noqa: E402
import montanha as MT  # noqa: E402
import gelo as GL  # noqa: E402
import nucleo as NC  # noqa: E402
import aliados as AL2  # noqa: E402
import aparencia as AP  # noqa: E402
import armas as AR  # noqa: E402
import props as PR  # noqa: E402
import tiles as TL  # noqa: E402
from pixel import canvas, hstrip, paste, upscale, rect, mix  # noqa: E402


def save(image, rel_path: str) -> None:
    path = os.path.join(ROOT, rel_path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.save(path)
    print("  ", rel_path, f"{image.width}x{image.height}")


def main() -> None:
    print("Personagens")
    save(hstrip(C.player_frames()), "assets/sprites/player.png")
    save(C.player_sword(), "assets/sprites/player_sword.png")
    save(AP.atlas(), "assets/sprites/player_aparencias.png")  # criacao de personagem
    save(hstrip(C.soldier_frames()), "assets/sprites/soldier.png")
    save(C.soldier_shield(), "assets/sprites/soldier_shield.png")
    save(C.soldier_baton(), "assets/sprites/soldier_baton.png")
    save(hstrip(C.helena_frames()), "assets/sprites/helena_body.png")
    save(C.helena_helmet(), "assets/sprites/helena_helmet.png")
    save(C.helena_pauldron_back(), "assets/sprites/helena_pauldron_back.png")
    save(C.helena_pauldron_front(), "assets/sprites/helena_pauldron_front.png")
    save(C.helena_breastplate(), "assets/sprites/helena_breastplate.png")
    save(C.helena_cape(), "assets/sprites/helena_cape.png")
    save(C.helena_sword(), "assets/sprites/helena_sword.png")
    save(C.helena_seated(), "assets/sprites/helena_seated.png")
    save(hstrip(C.dwarf_frames()), "assets/sprites/npc_ferreiro.png")
    save(hstrip(C.dragonoid_frames()), "assets/sprites/npc_vendedor.png")
    save(hstrip(C.fairy_frames()), "assets/sprites/npc_fada.png")
    save(hstrip(C.orb_frames()), "assets/sprites/npc_orbe.png")
    save(C.training_dummy(), "assets/sprites/training_dummy.png")
    save(hstrip(AL.aldir_frames()), "assets/sprites/aldir_body.png")
    save(AL.aldir_kneel(), "assets/sprites/aldir_kneel.png")
    save(AL.aldir_eyes(), "assets/sprites/aldir_eyes.png")
    save(AL.aldir_hammer(), "assets/sprites/aldir_hammer.png")

    print("Tiles")
    save(TL.theater_atlas(), "assets/tiles/teatro_tiles.png")
    save(TL.city_atlas(), "assets/tiles/cidade_tiles.png")

    print("Props")
    save(PR.seat("red"), "assets/props/seat_red.png")
    save(PR.seat("red", broken=True), "assets/props/seat_red_broken.png")
    save(PR.seat("tan"), "assets/props/seat_tan.png")
    save(PR.debris(), "assets/props/debris.png")
    save(hstrip(PR.torch_frames()), "assets/props/torch.png")
    save(PR.pillar(), "assets/props/pillar.png")
    save(PR.capsule(), "assets/props/capsule.png")
    save(hstrip(PR.forge_frames()), "assets/props/forge.png")
    save(PR.anvil(), "assets/props/anvil.png")
    save(PR.counter(), "assets/props/counter.png")
    save(PR.weapon_rack(), "assets/props/weapon_rack.png")
    save(PR.barricade(), "assets/props/barricade.png")
    save(PR.rubble_pile(), "assets/props/rubble.png")
    save(hstrip(PR.fire_frames()), "assets/props/fire.png")
    save(PR.lamp_post(), "assets/props/lamp_post.png")
    save(PR.gate(), "assets/props/gate.png")
    save(PR.crate(), "assets/props/crate.png")
    save(PR.car_wreck(), "assets/props/car_wreck.png")
    save(hstrip(AL.cover_frames()), "assets/props/cover.png")

    print("Efeitos")
    save(PR.light_texture(128), "assets/fx/light.png")
    save(PR.particle_square(2, (255, 255, 255)), "assets/fx/spark.png")
    save(PR.soft_dot(6, P.MEMORY), "assets/fx/mote.png")
    save(PR.particle_square(3, (180, 172, 160)), "assets/fx/dust.png")
    save(PR.shadow_blob(14, 6), "assets/fx/shadow.png")
    save(PR.shadow_blob(22, 8), "assets/fx/shadow_big.png")
    save(PR.shadow_blob(30, 10), "assets/fx/shadow_huge.png")
    save(AL.pit_cracks(), "assets/fx/pit_cracks.png")
    save(AL.pit_hole(), "assets/fx/pit_hole.png")
    save(AL.pit_rubble(), "assets/fx/pit_rubble.png")
    save(AL.crack_decal(), "assets/fx/crack_decal.png")
    save(AL.shock_rock(), "assets/fx/shock_rock.png")
    save(PR.cloud(1, 64, 24), "assets/fx/cloud_1.png")
    save(PR.cloud(2, 96, 32), "assets/fx/cloud_2.png")
    save(PR.cloud(3, 48, 18), "assets/fx/cloud_3.png")

    print("Prologo: o Complexo das Capsulas")
    save(PG.lab_atlas(), "assets/tiles/laboratorio_tiles.png")
    save(PG.wall_tally(), "assets/props/lab_tally.png")
    save(PG.wall_drawing(), "assets/props/lab_drawing.png")
    save(PG.wall_lamp(), "assets/props/lab_lamp.png")
    save(PG.wall_vines(), "assets/props/lab_vines.png")
    save(PG.capsule_occupied(), "assets/props/capsule_occupied.png")
    save(PG.capsule_empty(), "assets/props/capsule_empty.png")
    save(PG.capsule_broken(), "assets/props/capsule_broken.png")
    save(PG.terminal(), "assets/props/terminal.png")
    save(PG.cot(), "assets/props/cot.png")
    save(PG.toys(), "assets/props/toys.png")
    save(PG.plant(), "assets/props/plant.png")
    save(PG.cables(), "assets/props/cables.png")
    save(PG.long_table(), "assets/props/long_table.png")
    save(hstrip(PG.lab_door_frames()), "assets/props/lab_door.png")
    save(PG.lab_cracks(), "assets/fx/lab_cracks.png")
    save(PG.lab_hole(), "assets/fx/lab_hole.png")
    save(PG.child_sheet("a"), "assets/sprites/crianca_a.png")
    save(PG.child_sheet("b"), "assets/sprites/crianca_b.png")
    save(PG.child_sheet("teen"), "assets/sprites/adolescente.png")
    save(PG.wooden_sword(), "assets/sprites/wooden_sword.png")
    save(hstrip(PG.spared_child_frames()), "assets/sprites/crianca_poupada.png")
    save(PG.governess_seated(False), "assets/sprites/governanta_sentada.png")
    save(PG.governess_seated(True), "assets/sprites/governanta_olhando.png")
    save(PG.governess_sheet(False), "assets/sprites/governanta_body.png")
    save(PG.governess_sheet(True), "assets/sprites/governanta_solto.png")
    save(PG.governess_keys(), "assets/sprites/governanta_chaves.png")

    print("Cidade: Cao de Guerra, Atirador, Civil Cinzento")
    save(hstrip(CI.dog_frames()), "assets/sprites/cao.png")
    save(hstrip(CI.sniper_frames()), "assets/sprites/atirador.png")
    save(CI.rifle(), "assets/sprites/fuzil.png")
    save(CI.bullet(), "assets/fx/bala.png")
    save(hstrip(CI.civil_frames()), "assets/sprites/civil.png")
    save(hstrip(CI.sargento_frames()), "assets/sprites/sargento.png")
    save(CI.sabre(), "assets/sprites/sabre.png")
    save(hstrip(CI.couraca_frames()), "assets/sprites/couraca.png")
    save(CI.couraca_mace(), "assets/sprites/couraca_clava.png")

    print("Itens (inventario)")
    save(IT.icon_sucata(), "assets/items/sucata_temperada.png")
    save(IT.icon_fragmento(), "assets/items/fragmento_turvo.png")
    save(IT.icon_escudo(), "assets/items/escudo_remendado.png")
    save(IT.escudo_sprite(), "assets/sprites/escudo_heroi.png")
    save(IT.icon_espada(), "assets/items/espada.png")
    save(IT.icon_apito(), "assets/items/apito_sargento.png")
    save(IT.icon_lembranca((150, 230, 170), (70, 130, 96)), "assets/items/lembranca_governanta.png")
    save(IT.icon_lembranca((255, 170, 90), (150, 70, 30)), "assets/items/lembranca_aldir.png")
    save(IT.icon_lembranca((235, 100, 110), (130, 34, 50)), "assets/items/lembranca_helena.png")
    save(IT.icon_block(), "assets/ui/icon_block.png")

    print("Bosque do Sono Eterno")
    save(BQ.forest_atlas(), "assets/tiles/bosque_tiles.png")
    save(BQ.tree(), "assets/props/tree.png")
    save(BQ.bush(), "assets/props/bush.png")
    save(BQ.log(), "assets/props/log.png")
    save(BQ.sleeping_soldier(), "assets/props/sleeping_soldier.png")
    save(hstrip(BQ.waterfall_frames()), "assets/props/waterfall.png")
    save(BQ.pollen_cloud(), "assets/fx/pollen_cloud.png")
    save(BQ.zzz(), "assets/fx/zzz.png")
    save(hstrip(BQ.sleeper_frames()), "assets/sprites/sonambulo.png")
    save(hstrip(BQ.flower_frames()), "assets/sprites/flor_polen.png")
    save(hstrip(BQ.deer_frames()), "assets/sprites/cervo.png")
    save(hstrip(BQ.wither_frames()), "assets/sprites/fada_murcha.png")
    save(hstrip(BQ.guardian_frames()), "assets/sprites/vigia.png")
    save(BQ.guardian_club(), "assets/sprites/vigia_clava.png")
    save(hstrip(BQ.spore_mother_frames()), "assets/sprites/mae_esporos.png")
    save(hstrip(BQ.nyssa_frames()), "assets/sprites/nyssa.png")
    save(BQ.dream_bubble(), "assets/fx/dream_bubble.png")
    save(BQ.dream_shadow(), "assets/fx/dream_shadow.png")
    save(BQ.dream_hole(), "assets/fx/dream_hole.png")
    save(BQ.flower_bed(), "assets/props/flower_bed.png")
    save(IT.icon_lembranca((200, 182, 246), (96, 78, 150)), "assets/items/lembranca_nyssa.png")

    print("Raizes da Fome")
    save(RZ.roots_atlas(), "assets/tiles/raizes_tiles.png")
    save(RZ.root_tangle(), "assets/props/root_tangle.png")
    save(hstrip(RZ.flesh_pod_frames()), "assets/props/flesh_pod.png")
    save(RZ.planter(), "assets/props/planter.png")
    save(RZ.stove(), "assets/props/stove.png")
    save(RZ.mabel_table(), "assets/props/mabel_table.png")
    save(RZ.sap_splat(), "assets/fx/sap_splat.png")
    save(RZ.flesh_fruit(), "assets/fx/flesh_fruit.png")
    save(hstrip(RZ.root_vein_frames()), "assets/sprites/raiz_veia.png")
    save(hstrip(RZ.boca_frames()), "assets/sprites/boca_de_raiz.png")
    save(hstrip(RZ.inchado_frames()), "assets/sprites/inchado.png")
    save(hstrip(RZ.colhedor_frames()), "assets/sprites/colhedor.png")
    save(hstrip(RZ.larva_frames()), "assets/sprites/larva_seiva.png")
    save(hstrip(RZ.banqueteiro_frames()), "assets/sprites/banqueteiro.png")
    save(hstrip(RZ.ninhada_frames()), "assets/sprites/ninhada.png")
    save(hstrip(RZ.mabel_frames()), "assets/sprites/mabel.png")
    save(IT.icon_lembranca((226, 110, 104), (130, 36, 44)), "assets/items/lembranca_mabel.png")

    print("Forjas Ocas")
    save(FJ.forge_atlas(), "assets/tiles/forjas_tiles.png")
    save(FJ.chain_post(), "assets/props/chain_post.png")
    save(FJ.gear_pile(), "assets/props/gear_pile.png")
    save(FJ.press(), "assets/props/press.png")
    save(FJ.bronze_statue(), "assets/props/bronze_statue.png")
    save(FJ.wrench_hammer(), "assets/sprites/durgan_chave.png")
    save(hstrip(FJ.automaton_frames()), "assets/sprites/automato.png")
    save(hstrip(FJ.turret_frames()), "assets/sprites/torreta.png")
    save(hstrip(FJ.miner_frames()), "assets/sprites/minerador.png")
    save(hstrip(FJ.imitator_frames()), "assets/sprites/imitador.png")
    save(FJ.imitator_sword(), "assets/sprites/imitador_espada.png")
    save(FJ.imitator_shield(), "assets/sprites/imitador_escudo.png")
    save(hstrip(FJ.prototype_frames()), "assets/sprites/prototipo.png")
    save(hstrip(FJ.guardian_frames()), "assets/sprites/guardiao_ancora.png")
    save(hstrip(FJ.durgan_frames()), "assets/sprites/durgan.png")
    save(IT.icon_lembranca((190, 214, 240), (92, 110, 140)), "assets/items/lembranca_durgan.png")

    print("Montanha Carbonizada")
    save(MT.mountain_atlas(), "assets/tiles/montanha_tiles.png")
    save(MT.burnt_tree(), "assets/props/burnt_tree.png")
    save(MT.ribcage(), "assets/props/ribcage.png")
    save(MT.dragon_skull(), "assets/props/dragon_skull.png")
    save(MT.obsidian_spike(), "assets/props/obsidian_spike.png")
    save(MT.rock_cover_frames(), "assets/props/rock_cover.png")
    save(MT.scale_memorial(), "assets/props/scale_memorial.png")
    save(MT.fireball(), "assets/fx/bola_de_fogo.png")
    save(hstrip(MT.servant_frames()), "assets/sprites/dragonoide_atirador.png")
    save(hstrip(MT.beast_frames()), "assets/sprites/dragao_bestial.png")
    save(hstrip(MT.wyvern_frames()), "assets/sprites/dragao_alado.png")
    save(hstrip(MT.ember_frames()), "assets/sprites/brasa_viva.png")
    save(hstrip(MT.captain_frames()), "assets/sprites/capitao_dragonoide.png")
    save(hstrip(MT.matriarch_frames()), "assets/sprites/matriarca_bestial.png")
    save(hstrip(MT.rachel_frames()), "assets/sprites/rachel.png")
    save(IT.icon_lembranca((255, 170, 90), (150, 50, 30)), "assets/items/lembranca_rachel.png")

    print("Dominio Congelado")
    save(GL.frost_atlas(), "assets/tiles/gelo_tiles.png")
    save(GL.crystal_cluster(), "assets/props/crystal_cluster.png")
    save(GL.frozen_reader(), "assets/props/frozen_reader.png")
    save(GL.frozen_bookshelf(), "assets/props/frozen_bookshelf.png")
    save(GL.display_case(), "assets/props/display_case.png")
    save(GL.ice_pillar_frames(), "assets/props/ice_pillar.png")
    save(GL.lore_book(), "assets/props/lore_book.png")
    save(GL.arconte_staff(), "assets/props/arconte_staff.png")
    save(GL.ice_shard(), "assets/fx/estilhaco_gelo.png")
    save(GL.flying_book(), "assets/fx/livro_voando.png")
    save(GL.ice_block(), "assets/fx/bloco_de_gelo.png")
    save(hstrip(GL.librarian_frames()), "assets/sprites/bibliotecario_gelo.png")
    save(hstrip(GL.statue_frames()), "assets/sprites/estatua_viva.png")
    save(hstrip(GL.mite_frames()), "assets/sprites/acaro_cristal.png")
    save(hstrip(GL.apprentice_frames()), "assets/sprites/aprendiz_arcano.png")
    save(hstrip(GL.curator_frames()), "assets/sprites/curadora_vitrines.png")
    save(hstrip(GL.golem_frames()), "assets/sprites/golem_arquivo.png")
    save(hstrip(GL.cassian_frames()), "assets/sprites/cassian.png")
    save(GL.scholar(frozen=True), "assets/sprites/estudioso_congelado.png")
    save(GL.scholar(), "assets/sprites/estudioso.png")
    save(IT.icon_lembranca((190, 230, 255), (60, 110, 170)), "assets/items/lembranca_cassian.png")
    save(IT.icon_lembranca((246, 226, 160), (120, 96, 50)), "assets/items/lembranca_cavaleiro.png")
    print("Armas de chefe")
    for weapon_id in AR.WEAPONS:
        save(AR.hand(weapon_id), f"assets/sprites/arma_{weapon_id}.png")
        save(AR.icon(weapon_id), f"assets/items/{weapon_id}.png")

    print("O Nucleo")
    save(NC.core_atlas(), "assets/tiles/nucleo_tiles.png")
    save(NC.ruin_column(), "assets/props/ruin_column.png")
    save(NC.flower_bush(), "assets/props/flower_bush.png")
    save(NC.broken_arch(), "assets/props/broken_arch.png")
    save(NC.sin_statue(), "assets/props/sin_statue.png")
    save(hstrip(NC.knight_frames()), "assets/sprites/cavaleiro.png")
    save(hstrip(NC.woman_frames()), "assets/sprites/mulher_nucleo.png")
    save(NC.falling_stone(), "assets/fx/pedra_caindo.png")

    print("Interface")
    save(PR.icon_attack(), "assets/ui/icon_attack.png")
    save(PR.icon_dash(), "assets/ui/icon_dash.png")
    save(PR.icon_heal(), "assets/ui/icon_heal.png")
    save(PR.icon_sanity(), "assets/ui/icon_sanity.png")
    save(PR.icon_interact(), "assets/ui/icon_interact.png")
    save(PR.icon_memory(), "assets/ui/icon_memory.png")
    save(PR.icon_pause(), "assets/ui/icon_pause.png")

    print("Icone do app")
    island = PR.app_icon_island(32)
    save(upscale(island, 6), "icon.png")  # 192x192 (icone principal / Android)
    island_only = PR.app_icon_island(32, with_sky=False)
    fg = canvas(432, 432)
    paste(fg, upscale(island_only, 8), (432 - 256) // 2, (432 - 256) // 2)  # dentro da zona segura de 264px
    save(fg, "assets/icon/icon_foreground.png")
    mono = fg.copy()  # ícone "temático" do Android 13+: silhueta branca
    px = mono.load()
    for y in range(mono.height):
        for x in range(mono.width):
            if px[x, y][3] > 0:
                px[x, y] = (255, 255, 255, 255)
    save(mono, "assets/icon/icon_monochrome.png")
    bg = canvas(432, 432)
    for y in range(432):
        rect(bg, 0, y, 432, y + 1, mix(P.SKY_TOP, P.SKY_BOTTOM, y / 432))
    save(bg, "assets/icon/icon_background.png")

    print("Aliados")
    save(hstrip(AL2.guard_frames()), "assets/sprites/guarda.png")
    save(AL2.guard_frames()[0], "assets/sprites/guarda_npc.png")  # parado (o NPC de conversa)
    save(AL2.empty_post(), "assets/props/posto_vazio.png")
    save(AL2.ring_icon(), "assets/items/anel_do_guarda.png")

    print("Loja (Play Store)")
    os.makedirs(os.path.join(ROOT, "docs/loja"), exist_ok=True)
    store_icon = canvas(32, 32)
    paste(store_icon, PR.app_icon_island(32), 0, 0)
    save(upscale(store_icon, 16), "docs/loja/icone_512.png")  # 512x512, exigido pela Play Console

    print("Paleta (docs)")
    swatches = [getattr(P, n) for n in dir(P) if n.isupper() and isinstance(getattr(P, n), tuple)]
    sheet = canvas(16 * 12, 16 * ((len(swatches) + 11) // 12))
    for i, color in enumerate(swatches):
        x, y = (i % 12) * 16, (i // 12) * 16
        rect(sheet, x, y, x + 16, y + 16, color)
    save(upscale(sheet, 2), "docs/referencias/paleta.png")


if __name__ == "__main__":
    main()

# Gavetas e corrediças da biblioteca antiga (moldes)

Estrutura e contrato do kit em `regras/02`. Fórmulas completas nos dumps de `referencia/`. Cena de referência
`G:\Meu Drive\corrediças_sabin.skp`.

## Moldes na cena
| Gaveta (nível de cima) | Kit | itemcode | Observação |
|---|---|---|---|
| `conteiner` | `kit_corredica_hd_invisivel` (oculta HD Invisível FGVTN, soft close) | `"CM_KIT_COR_INV_FGVTN_AM_"&LenY*10` | 300–550 (`minlength` 35/`maxlength` 50 no molde, o summary diz 300–550); folga e carro corrigidos 23/10 |
| `conteiner#12` | `corredica_hafele_telescopica_normal` (Häfele H45 S) | `"CM_KIT_COR_HAFELE_H45_S_NR_"&upmdepth` | `summary`: até 25 kg, extração total |

Medidas no vão de 500 × 500 do molde (gaveta 450): frente do móvel = `edge_conteiner` (y mín.); o kit fica 1 mm à frente.

### Häfele H45 S (telescópica)
- Folga da gaveta 13 mm por lado (`diffbodyrail` 2.6): corpo da gaveta 474 de 500.
- Furos do móvel (base, da frente do perfil, cm): `3.5`, `16.3` e o de trás por tabela
  `if(parent!leny=25,16.3, 30→25.9, 35→25.9, 40→35.5, 45→38.7, 50→38.7, 55→38.7, 60→38.7, 65→57.9, 70→57.9, 3.5)`.
- Furos da gaveta (trilho): `3.5`, `16.3` e `if(parent!leny=25,3.5, 30–40→25.9, 45–60→38.7, 65–70→57.9)`.
- Logo `logo_hafele` (face com textura) e texto "Normal" no `trilho_interno`, com `lenx/leny` por fórmula.

### HD Invisível (oculta)
- Furos do móvel no lado: `3.3+0.5` (37 mm da frente do móvel), `16.1+0.5` (165), `if(parent!leny<=35,19.8,26.2)`
  (261 em 400+); furo traseiro da gaveta `y = if(parent!open=0,parent!leny,0…)`, x do pino.
- Carro com grupo "FGVTN" + "Soft Closing" (texto) + "HD" (oculto), sem fórmula de tamanho.
- Antes da correção: `diffbodyrail` 1.1 (gaveta 489 de 500) e `base_gaveta` com `kit_corredica!diffbody` (cortado).

## Outros moldes de corrediça no catálogo (não estão na cena)
`corredica_tn_telescopica_normal` (`CM_KIT_COR_TN_H45_NR_`&upmdepth, keyalert 300–500, mesma estrutura da Häfele),
`corredica_hafele_telescopiaca_amortecedor` (`..._H45_S_SC_`), `kit_corredica_invisivel_generica` (`COR_INV_TOP_`&LenY,
"somente guia com furos", `parentrefresh 3`), `corredica_hettich_quadro_v6_sisy(_soft)`, `kit_corredica_HARDT_invisivel_com_amortecedor`,
`kit_corredica_hafele_invisivel_matrix_a30_gt2_sc`. Ver `referencia/estudo_catalogo.txt` (TN e genérica) e
`scripts/estuda_catalogo.rb` para os outros.

## Feitos a partir destes moldes
`componentes/corredicas_fulterer_unihide.md`.

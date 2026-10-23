# 02 · Estrutura da biblioteca antiga (Upmobb)

Tirado da cena `G:\Meu Drive\corrediças_sabin.skp` (gavetas `conteiner` = HD Invisível e `conteiner#12` = Häfele H45 S)
e dos moldes do catálogo do plugin (`referencia/catalogo_plugin.md`). Dumps completos (todas as fórmulas):
`referencia/dump_gaveta_hd_invisivel.txt`, `referencia/dump_gaveta_hafele_h45.txt`, `referencia/estudo_catalogo.txt`.
Procure neles com Grep antes de abrir a cena.

## Como reconhecer
| | Antiga (Upmobb) — **esta pasta** | Grossl (outra pasta: `Desktop\upmobb_componentes`) |
|---|---|---|
| Códigos | `CM_*` (`CM_LEG`, `CM_CFG`, `CM_FUN_GAV_VER`, `CM_FRE_GAV_LIS`, `CM_KIT_COR_*`, `CM_BAL_TAM`, `CM_POR_LIS`), `COM_AVU` | `PC_*`, `GAV`, `COR_OCU_*`, `BAL` |
| Peça | `lateral_esquerda_gaveta`, `contra_frente_gaveta`, `lateral_direita`, `base`, `tampo` (type `peace\|composed`) | `pec_leg`, `pec_cfg`, `pec_lat_esq`... |
| Medida da peça | `a1_height`, `a2_length` (ou `a2_width`), `a3_thickness` | `a1_length`, `a2_width`, `a3_thickness` |
| Gaveta | `conjunto_gavetas_Nund` > `gaveta` > `base_gaveta` > `corpo_gaveta` + `kit_corredica` | `gavetas_N_unidades` > `fix_caixa_gaveta` > `fix_modelo_gaveta` > `fix_corredica` |
| Corrediça | `kit_corredica_<modelo>` / `corredica_<marca>_<modelo>` (`_name` `kit_corredica`) | `fix_corredica_<nome>` |
| Comprimento da corrediça | a **gaveta** escolhe (`lengthrails`) | a corrediça escolhe (`raillength`) |
| Abrir | `gaveta.onclick = set("extract",1,0)`; kit `open = parent!extract` | `onclick` na frente, `moveopen` |
| Caixa do balcão | `caixa_balcao` (`_name` `caixa_upm` ou `caixa_balcao`) | `fix_caixa_upm` |

Componente que mistura as duas (ex.: `fix_*` dentro de um `conjunto_gavetas`) não é desta biblioteca: pergunte.

## Gaveta (molde: `conteiner` da cena)
```
conteiner                     COM_AVU "Estrutura", type conteiner_bottom|conteiner_top|conteiner_external|conteiner_panel|
 │                            conteiner_internal|conteiner_drawer|door|peace; lenx/leny/lenz fixos (50/50/122 cm)
 ├─ edge_conteiner (2)        caixa de seleção (o vão interno: 500 de largura no molde)
 └─ conjunto_gavetas_1und     _name conjunto_gavetas; campos internal, quantity, transpasse*, heightmax, spacebetween,
     │                        positionbodyforfront, reduceagainstfront; clearancebetween 0,35, clearanceupdown 2,5
     └─ gaveta                type conteiner_drawer "Gaveta MDF"; onclick set("extract",1,0)
         ├─ base_gaveta       "sistema corrediça"; leny = parent!lengthrails-kit_corredica!reduceforbody
         │   ├─ corpo_gaveta  lenx = parent!lenx-parent!diffbodyrail, x = parent!diffbodyrail/2
         │   │   ├─ contra_frente_gaveta (CM_CFG), traseira_gaveta, lateral_esquerda/direita_gaveta (CM_LEG...)
         │   │   │   └─ kit_minifix15_twister nas pontas
         │   │   └─ conteiner (vão interno) > fundo_vertical_gaveta (CM_FUN_GAV_VER, rasgos Transfer_vertical_saw_cut)
         │   └─ kit_corredica_<modelo>   a corrediça (ver abaixo)
         ├─ frente_gaveta     CM_FRE_GAV_LIS > chapa_frente_gaveta (+ kit_parafuso). No catálogo há a variante
         │                    frente_gaveta > caixa_frente_de_gaveta > chapa_frontal.
         └─ grupo alert
```
- **gaveta**: `lengthrails` = maior corrediça que cabe (`lenyforextract >= 70+clearancerear` … 25) ou `lengthdefinition`
  (LIST "Profundidade definida": auto=0, 250mm=25 … 700mm=70); `clearancerear` 2; `heightmin` 7; `thickness` 1.55
  (LIST 15/18); `thicknessbackground` (LIST 3/6/15/18); `positionbackground`; `heightreduce`; `diffsidefront`.
  `keyalert` = fundo 3 mm sem rasgo, profundidade < corrediça+folga, corrediça > 55, altura < mínimo.
  `summary` mostra "Corrediça de <mm>" e os avisos em vermelho.
- **base_gaveta** lê do kit: `diffbodyrail = kit_corredica!diffbodyrail` (folga lateral **total**, cm: caixa da
  gaveta = vão − diffbodyrail) e `reduceforbody = kit_corredica!reduceforbody`. `z = reducenominal`.
- `extract = 1`: a gaveta dobra a profundidade (`leny`) e a base anda para a frente (`-parent!lenyforextract+leny`).

## Corrediça (kit) — o contrato
O kit fica dentro da `base_gaveta` e lê dela: `lenx = parent!lenx` (vão), `leny = parent!leny` (= `lengthrails`,
comprimento da corrediça), `thickness = parent!thickness` (lateral da gaveta), `open = parent!extract`.
O kit entrega: `diffbodyrail` (cm, total dos 2 lados) e `reduceforbody` (cm). Identidade: `itemcode`
`"CM_KIT_COR_<tipo>_<marca>_<modelo>_"&<len>`, `upmcode = itemcode`, `description`, `name` "Corrediça",
`modeloptions` ("corrediça invisivel" / "corrediça telescopica": é o grupo da troca de modelo), `componentedit 1`,
`parentrefresh` 2 ou 3, `upmwidth/upmheight/upmdepth`.

### Telescópica (moldes `corredica_hafele_telescopica_normal`, `corredica_tn_telescopica_normal`, `..._amortecedor`)
```
kit  leny = if(open=1,2*parent!leny,parent!leny)   lenyforopen = if(open=0,leny,leny/2)   lenz 4.4
     positionrails LIST (Centro=0 / Inferior=1), z = if(positionrails=0,parent!lenz/2-lenz/2,0)
     diffbodyrail 2.6 (13 mm de cada lado)   upmwidth 13   upmdepth = lenyforopen*10   atttransfer positionrails
 ├─ CorrediçaEsq (x 0, y -leny)  /  CorrediçaDir (x parent!lenx, y -LenY)    leny = parent!lenyforopen
 │   ├─ BaseCorrediçaTelescopica*   perfil do móvel, y +0.1; 3 furos "Transfer Hole" (p_3mm) x 0 / parent!lenx
 │   └─ TrilhoCorrediçaTelescopica* perfil da gaveta, y = if(parent!open=0,0,-(leny)); 3 furos x parent!lenx / -1.25
 │       └─ trilho_interno > logo_hafele (textura) + "Normal" (texto)  — virados para o móvel
```
Furos: `y` = distância da frente do perfil (cm), tabela por comprimento em `if(parent!leny=25,…,if(…))`.
O kit fica 1 mm à frente do móvel (frente do móvel = `edge_conteiner`).

### Oculta (moldes `kit_corredica_hd_invisivel`, `kit_corredica_invisivel_generica`, Hettich Quadro V6, Hardt, Matrix A30)
```
kit  lenz 4.85   minlength/maxlength (cm)   keyalert = if(or(leny>maxlength,leny<minlength),0,1)
     upmdisable = not(keyalert)   summary com o alerta   upmwidth 40*10   diffbodyrail (HD: 1.1 — errado, ver abaixo)
 ├─ corredica_esquerda (x 0) / corredica_direita (x parent!lenx)    lenx 5.25, leny parent!leny
 │   ├─ BaseCorredicaOculta   perfil do móvel (HD: leny 28 FIXO)
 │   ├─ carro_corredica       perfil da gaveta: y = if(parent!open=1,-(parent!leny-4.6),4.6); x 2.2 (HD)
 │   │   └─ textos/logo (HD: grupo "FGVTN", "Soft Closing", "HD" oculto) — SEM fórmula de tamanho
 │   ├─ pino_guia, rebaixo_gaveta (Transfer_vertical_saw_cut, upmtool r_f, oculto)
 │   └─ 4 grupos "Transfer Hole" NO LADO (não na base): 3 do móvel (x 0, y da frente) + 1 traseiro da gaveta
```

## Balcão na cena (molde: `balcao#1`, CM_BAL; dump `referencia/dump_balcao_cm_bal.txt`)
```
balcao (CM_BAL, _name balcao)
 ├─ caixa_balcao (_name caixa_upm)   lateral_direita/esquerda (+ kit_minifix15_twister), base (+ minifix), 
 │                                    conjunto_fixação_dianteira > regua_deitada (+ minifix), conjunto_fixação_traseira,
 │                                    fundo_horizontal_rasgo (corte_de_serra = transfer_saw)
 └─ conteiner (vão)                   > porta_giro_dupla_arezzo > porta_de_giro_dir/esq_arezzo >
                                        conjunto_dobradica_hafele_110_sm_click > dobradica (+ variantes de engate ocultas)
```
Armário alto oblíquo (CM_AR_ALT_CAN_OBL) > `caixa_aerea`: dump `referencia/dump_armario_alto_obliquo.txt`.

## Balcão e outros (catálogo; confira na cena antes de usar)
- `balcao_com_tampo` (CM_BAL_TAM, `_name` balcao): campos lenx/leny/lenz, thickness, `typeassembly` (Base passante /
  Lateral passante), `activehiddenpeace`, `positionbackground`, `1elevation`; filho `caixa_balcao` > lateral_esquerda/
  direita, base, tampo, conteiner, tamponamento(s).
- `caixa_balcao` (`_name` caixa_upm, type conteiner_external|conteiner_bottom, `parentrefresh 1`): laterais com
  `usinagem_ponto_a_ponto_n*`, `conjunto_fixação_dianteira/traseira` (regua_deitada), `fundo_horizontal_rasgo`
  (corte_de_serra = transfer_saw), base com `kit_minifix15_twister`.
- `prateleira_1und` (quantity LIST 1–10, indentation, mz, thickness) > prateleira(s); `divisoria_1und` (conteiners
  + divisoria + kit_parafuso).
- `porta_de_giro_sem_puxdor` (CM_POR_LIS, `_name` porta_giro, onclick set(open,1,0), positionopen, positionpuller,
  tselecttypehinge, transpasses) > chapa_porta_vertical + conjunto_dobradica_hafele_110_sm_click > dobradica.

## Erros conhecidos dos moldes antigos (já vistos)
- Gaveta da HD: `base_gaveta._diffbodyrail_formula` cortada (`kit_corredica!diffbody`): nunca lia a folga do kit.
  Corrigida na cena (23/10). Procure o mesmo nos outros moldes: `Grep "kit_corredica!diffbody\b"` nos dumps.
- HD: `diffbodyrail` 1,1 fixo (5,5 mm por lado) e carro a 22 mm: com a folga certa ele entra no MDF.
  Certo (manual UniHide, mesma família): 24,5 até a face **interna** da lateral → `2*(2.45-parent!thickness)`.
- HD: `BaseCorredicaOculta` com 280 mm fixos (furo de trás cai fora do metal em 450+).
- Os dumps da HD foram tirados **depois** dessas correções (diffbodyrail por fórmula, carro em 2.45+0.1).

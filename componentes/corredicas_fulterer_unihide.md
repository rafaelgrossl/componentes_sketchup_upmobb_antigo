# Corrediças Fulterer (FR 5045 / 5047 / 5046 ECD / 5210 OE ECD, ocultas 40 kg / 60 kg) e UniHide Slowmotion (FGVTN)

Cena `G:\Meu Drive\corrediças_sabin.skp`. Manuais em `G:\Meu Drive\ferragens manuais` (cópia local em `..\upmobb_componentes\ferragens\manuais`:
desenhos `FR_50xx.0<len>_mm.pdf`, `5046.<len>-GA…pdf`, `FR_5210.0<len>_ECD_mm.pdf`, `Corredica_Unihide_slow.pdf`, STEP da 5210).

Scripts: `corredicas_fulterer_unihide.rb` (cria tudo) · `corredicas_fulterer_confere.rb` (furos em mm da frente do
móvel, textos) · `corredicas_fulterer_testes.rb` (270–600, desfeito) · `apaga_gavetas_teste.rb` (apaga as gavetas e
só as definições que ficaram sem uso, para refazer) · `foto_corredica_aberta.rb` (foto da minifoto).

## Moldes e gavetas de teste
| Gaveta (nível de cima) | Kit | Molde |
|---|---|---|
| `conteiner_gaveta_fulterer_fr5045` / `_fr5047` / `_fr5046_ecd` / `_fr5210_oe_ecd` (x +700…+2800 do `conteiner#12`) | `corredica_fulterer_<modelo>` | `corredica_hafele_telescopica_normal` (Häfele H45 S) |
| `conteiner_gaveta_fgvtn_unihide_slowmotion` (x +700 do `conteiner`) | `kit_corredica_fgvtn_unihide_slowmotion` | `kit_corredica_hd_invisivel` (HD Invisível FGVTN) |

Cópia independente de tudo (`make_unique` recursivo); as definições do kit levam o sufixo do modelo.
Comprimento = profundidade da gaveta (`parent!leny`, como no molde).

## Fulterer (telescópicas de montagem lateral)
Estrutura do molde: `CorrediçaEsq/Dir` > `BaseCorrediçaTelescopica*` (perfil do móvel, 3 furos) e
`TrilhoCorrediçaTelescopica*` (perfil da gaveta, 3 furos) > `trilho_interno` (logo + texto do modelo).
- `description` "Corrediça Telescópica Fulterer <modelo>", `itemcode` `"CM_KIT_COR_FULTERER_<cod>_"&upmdepth`
  (**provisório**), `codfabricante` `"FR 5045.0"&upmdepth` (5046: `…&" ECD"`, 5210: `…&" OE ECD"`).
- `lenz` 4,5 / 4,7 / 4,55 / 5,19 (altura do manual), `diffbodyrail` 2,6 (5210: 2,7), `upmwidth` 13 (5210: 13,4).
- Base e trilho 2 mm atrás da frente do móvel (folga frontal): base `y = 0.3`, trilho `y = if(parent!open=0,0.2,-(leny)+0.2)`.
- **Furos do móvel** (desenho Fulterer, mm do início do perfil = y local; o perfil fica 2 mm atrás da frente do móvel):
  os ø6,2 do sistema 32: frente **35**, meio **99** (ou **259** se o último passa de 291) e o **último ø6,2** do perfil
  (`C5045` / `C5046` / `C5210` no script). 5047 = 5045. 5046 250: 35/7/99, 300: 35/67/99 (só existem esses ø6,2).
  (Até 23/10 estava 37/69/tabela da oculta: errado, aquela tabela é das Fulterer **ocultas**.)
- **Furos da gaveta** (da ponta do perfil da gaveta): rasgo da frente (32), do meio e de trás. FR 5045 e **FR 5047**
  = `G5045`; FR 5210 = `G5210`; FR 5046 = `G5046`. Nos desenhos da 5047 / 5046 o 0 fica 3,2 / 1,8 **atrás** da ponta
  (28,8 + 3,2 = 32): some a diferença. Até 23/10 a 5047/5046 estavam com o padrão da 5045 **menos** isso (errado).
- `minlength` 27 (5210: 40), `maxlength` 60; `keyalert = if(or(parent!leny>maxlength,parent!leny<minlength),0,1)`;
  `summary` com a lista e "Comprimento fora da tabela" em vermelho.
- Logo: `logo_fulterer` (texto 3D "Fulterer", Arial negrito itálico 6 mm, plano, com arestas, material
  `Fulterer - Logo` 226,0,26) no lugar do `logo_hafele`; `texto_fulterer_<modelo>` (4 mm, cinza) no lugar do "Normal".
  Ficam no perfil que corre, virados para o móvel (como no molde): aparecem com a gaveta aberta.

## Ocultas Fulterer 40 kg / 60 kg (com amortecedor, sem manual)
Copiadas da UniHide (mesma folga N − 49, carro, pino), gavetas `conteiner_gaveta_fulterer_oculta_40kg` / `_60kg`
(x +1400 / +2100 do `conteiner`), kits `kit_corredica_fulterer_oculta_40kg` / `_60kg`.
- Furos do móvel (tabela do usuário, da frente do móvel, já com a folga frontal de 2 mm): 37, 69 e o último:
  40 kg 270/300/350/400/450/500/550/600 → 165/229/261/261/293/325/325/389; 60 kg 450/500/600 → 293.
  `y` local = valor + 0,1 (o kit fica 1 mm à frente do móvel). `minlength` 27 / 45, `maxlength` 60.
- `description` "Corrediça Oculta Fulterer 40kg/60kg", `itemcode` `"CM_KIT_COR_OCU_FULTERER_40KG_"&LenY*10`
  (**provisório**), `codfabricante` vazio (o usuário não passou). Carro: sem o logo FGVTN, texto "Fulterer" vermelho.

## UniHide Slowmotion (oculta, FGVTN)
- `description` "Corrediça Oculta UniHide Slowmotion", `itemcode` `"CM_KIT_COR_OCU_FGVTN_UNIHIDE_"&LenY*10`
  (**provisório**), `codfabricante` `54OC1812<len>TSX0` (manual), `minlength` 30, `maxlength` 55, alerta no summary.
- Furos do móvel: os 3 furos do molde ficam no **lado** (`corredica_esquerda/direita`), não na base. Viram 37 / 69 /
  37+E (E do manual: 300–400 = 224, 450 = 256, 500–550 = 288) → `y = 3.3+0.5`, `6.9+0.1`, tabela `+0.1`
  (o kit fica 1 mm à frente do móvel). O 4º furo (pino traseiro) não mudou.
- Folga da gaveta: manual = vão **interno** da gaveta N − 49 (24,5 mm da lateral do móvel até a face **interna** da
  lateral da gaveta; lateral de 15 a 19 mm). `diffbodyrail = 2*(2.45-parent!thickness)` (lateral 15,5 → 1,8 = 9 mm por
  fora de cada lado). A `base_gaveta` do molde HD lia `kit_corredica!diffbody` (fórmula cortada) e ficava em 1,1; na
  cópia vira `kit_corredica!diffbodyrail`. Conferido: faces internas das laterais em 24,5 e 475,5 de um vão de 500.
- Perfil da gaveta a partir da face interna da lateral (24,5): `carro_corredica` x = `2.45+0.1`, `pino_guia` e furo
  traseiro (`_y_formula` com `open`) `2.45+0.7` (7 mm do manual), `rebaixo_gaveta` `2.45+0.3`; lado direito negativo.
  Furo do pino traseiro: 7 mm da face interna da lateral, 38 mm acima da base da corrediça = 11 mm acima do apoio
  da gaveta no carro (`z 3.8` do molde: certo; a gaveta apoia 27 mm acima da base). Broca ø7: `upmtool` f_7mm,
  `upmdiameter` 7 (o molde HD tinha f_5mm).
  O molde tinha o carro a 22 mm e ele entrava 2,5 mm no MDF da lateral. A HD original recebeu o mesmo
  (`scripts/hd_invisivel_folga.rb`).
- Base (`BaseCorredicaOculta`): `leny = parent!leny-1` (o molde tinha 280 mm fixos e o furo de 293/325 caía fora do metal).
- Carro: fica o logo FGVTN do molde (grupo); o texto "HD" sai e "Soft Closing" vira `texto_fgvtn_unihide`
  ("UniHide", 5 mm, verde `FGVTN - Logo`) **sem DC** (`troca_texto_plano`): com `lenx/leny` o DC parava de escalar o
  carro (587 mm em vez de 413, saindo da gaveta). O texto estica com o comprimento, como o "Soft Closing" do molde.
  Conferir contra o molde: `scripts/compara_gavetas.rb`.

## Conferido (23/10/2026, refeito no SketchUp 2027)
`corredicas_fulterer_confere.rb` em 450 (mm da frente do móvel): móvel 37/261/389 (5045, 5047), 37/101/261 (5046,
5210), 37/69/293 (UniHide e ocultas Fulterer); gaveta 33/193/385 (5045, 5047), 33/193/344 (5046), 33/161/353 (5210)
— perfil da gaveta 1 mm atrás da frente do móvel. `corredicas_fulterer_testes.rb` 250–700: todos batem com os
desenhos / tabelas (na 5046 e 5210 o teste mede da ponta do perfil, que fica 5,2 / 14,7 mm à frente: desconte).
Pino traseiro: f_7mm ø7, z 66,1 (38 da base da corrediça) nas três ocultas.
Minifotos: `corredica_oculta_40kg_amortecedor.jpg` / `_60kg_` (render, logo Fulterer).
## Pendente / confirmar
- Ocultas Fulterer: modelo/código de fábrica e manual (folga e pino copiados da UniHide).
- Manual: `FR_5047.0600_mm.pdf` tem o desenho de 650; não há 5047 de 350 (usado o da 5045).
- Altura dos furos (a do molde Häfele / HD).
- Códigos `CM_KIT_COR_FULTERER_*` e `CM_KIT_COR_OCU_FGVTN_UNIHIDE_*` no ERP; carga da FR 5045 (não achada).
- FR 5210 é sobre-extração (25 mm além): o movimento de abrir usa o do molde (extração total).

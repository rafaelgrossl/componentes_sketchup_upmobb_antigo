# Corrediças Fulterer (FR 5045 / 5047 / 5046 ECD / 5210 OE ECD) e UniHide Slowmotion (FGVTN)

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
- **Furos do móvel** (da frente do móvel, já com os 2 mm): 37, 69 e o último pela tabela do usuário:
  40 kg (270/300/350/400/450/500/550/600 → 165/229/261/261/293/325/325/389) na FR 5045;
  60 kg (450/500/600 → 293; os outros da tabela 40 kg) na FR 5047, FR 5046 ECD e FR 5210 OE ECD.
  Fórmula do furo (y local da base) = valor − 0,2.
- **Furos da gaveta** (do início do perfil da gaveta): frente, 1º furo do grupo do meio e do grupo de trás do desenho
  Fulterer. FR 5045: 32 / 64–256 / 192–544 (ver `G5045` no script); FR 5210: `G5210` (400–700);
  FR 5047 e 5046 = padrão da 5045 menos 3,2 / 1,8 mm (1ª cota 28,8 / 30,2 do desenho delas) — **aproximado**.
- `minlength` 27 (5210: 40), `maxlength` 60; `keyalert = if(or(parent!leny>maxlength,parent!leny<minlength),0,1)`;
  `summary` com a lista e "Comprimento fora da tabela" em vermelho.
- Logo: `logo_fulterer` (texto 3D "Fulterer", Arial negrito itálico 6 mm, plano, com arestas, material
  `Fulterer - Logo` 226,0,26) no lugar do `logo_hafele`; `texto_fulterer_<modelo>` (4 mm, cinza) no lugar do "Normal".
  Ficam no perfil que corre, virados para o móvel (como no molde): aparecem com a gaveta aberta.

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
  O molde tinha o carro a 22 mm e ele entrava 2,5 mm no MDF da lateral. A HD original recebeu o mesmo
  (`scripts/hd_invisivel_folga.rb`).
- Base (`BaseCorredicaOculta`): `leny = parent!leny-1` (o molde tinha 280 mm fixos e o furo de 293/325 caía fora do metal).
- Carro: fica o logo FGVTN do molde (grupo); o texto "HD" sai e "Soft Closing" vira `texto_fgvtn_unihide`
  ("UniHide", 5 mm, verde `FGVTN - Logo`) **sem DC** (`troca_texto_plano`): com `lenx/leny` o DC parava de escalar o
  carro (587 mm em vez de 413, saindo da gaveta). O texto estica com o comprimento, como o "Soft Closing" do molde.
  Conferir contra o molde: `scripts/compara_gavetas.rb`.

## Conferido (23/10/2026)
`corredicas_fulterer_confere.rb` em 450: móvel 37/69/293 nas 5; gaveta 33/193/385 (5045), 29,8/189,8/381,8 (5047),
31,2/191,2/383,2 (5046), 33/161/353 (5210) — perfil da gaveta 1 mm atrás da frente do móvel.
`corredicas_fulterer_testes.rb` 270–600: último furo segue a tabela; alerta testado (300 e 650 na 5210, 650 na 5045).

## Pendente / confirmar
- Qual tabela vai em cada Fulterer (o usuário não escolheu: 40 kg na 5045, 60 kg nas outras).
- Furos da gaveta da FR 5047 / 5046 ECD (aproximados) e altura dos furos (a do molde Häfele / HD).
- Códigos `CM_KIT_COR_FULTERER_*` e `CM_KIT_COR_OCU_FGVTN_UNIHIDE_*` no ERP; carga da FR 5045 (não achada).
- FR 5210 é sobre-extração (25 mm além): o movimento de abrir usa o do molde (extração total).

# 05 · Nomes, códigos e trabalhos (biblioteca antiga)

## name e description (pedido do usuário)
- Sem caixa alta: "Tampo", "Lateral direita", "Corrediça". `name` sempre no **singular**.
- `description` diz qual é: "Corrediça Telescópica Fulterer FR 5045", "Lateral Esquerda Gaveta".
- Grave na definição e na instância (quando a instância tiver a chave).

## Nome da definição
- Minúsculo com `_`. Padrões desta biblioteca: `conjunto_*` (gavetas, fixações, dobradiças, puxadores), `kit_*`
  (ferragens: `kit_minifix15_twister`, `kit_parafuso`, `kit_corredica_<modelo>`), `corredica_<marca>_<modelo>`,
  `conteiner`, `caixa_balcao`, peças pelo nome (`lateral_esquerda_gaveta`, `fundo_vertical_gaveta`, `base`, `tampo`).
  **Não** use os padrões da Grossl (`fix_*`, `pec_*`, `com_pec_*`).
- `_name` = o que os irmãos/pais leem (`kit_corredica`, `base_gaveta`, `gaveta`, `conjunto_gavetas`): **não troque**.
  A `base_gaveta` lê `kit_corredica!…`: a corrediça nova precisa manter `_name = kit_corredica`.
- Gaveta de teste de um modelo novo: `conteiner_gaveta_<marca>_<modelo>`; definições do kit com `_<modelo>` no fim.

## Códigos (`itemcode` / `upmcode`)
- Maiúsculas com `_`. Vão para orçamento e ERP: **não invente**; reaproveite o do molde e avise para confirmar.
- Já usados nesta biblioteca: `COM_AVU` (conteiner avulso), `CM_LEG`/`CM_LDG` (laterais da gaveta), `CM_TRG` (traseira), `CM_CFG`
  (contra-frente), `CM_FUN_GAV_VER` (fundo da gaveta), `CM_FRE_GAV_LIS` (frente lisa), `CM_BAL_TAM` (balcão com tampo),
  `CM_POR_LIS` (porta de giro lisa), `CM_KIT_MIN15TW_*`, `CM_KIT_PAR_*`, `CAV_8X28`.
- Corrediças: `CM_KIT_COR_HAFELE_H45_S_NR_<len>` (Häfele normal), `CM_KIT_COR_HAFELE_H45_S_SC_<len>` (amortecedor),
  `CM_KIT_COR_TN_H45_NR_<len>`, `CM_KIT_COR_INV_FGVTN_AM_<len>` (HD Invisível), `CM_KIT_COR_INV_HETTICH_*`,
  `CM_KIT_COR_INV_HARDT_<len>`, `CM_KIT_COR_INV_HAFELE_MX_A30_SC_<len>`, `COR_INV_TOP_<len>` (genérica).
  **Provisórios** (criados 23/10, confirmar no ERP): `CM_KIT_COR_FULTERER_<modelo>_<len>`, `CM_KIT_COR_OCU_FGVTN_UNIHIDE_<len>`.
- Lista completa de códigos dos moldes: `referencia/catalogo_plugin.md`.

## Trabalhos de máquina (`upmtool`)
Têm que existir no cadastro de usinagens da máquina. Vistos nos moldes antigos: `p_3mm` (furo da corrediça),
`r_f` (rebaixo/rasgo de serra), `f_5mm`. Os do minifix/cavilha ainda não foram conferidos nos moldes antigos
(na Grossl: `f_15mm_tambor_min`, `f_5mm_twister243`, `f_8mm_cavilha`, `p_8mm_cavilha`). Trabalho novo: pergunte o nome exato ao usuário.

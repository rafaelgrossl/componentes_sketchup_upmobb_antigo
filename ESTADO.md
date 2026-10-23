# Estado atual (atualize ao fim de cada sessão)

Última atualização: 23/10/2026 (pasta criada a partir da sessão da Grossl).

## Feito
- Pasta criada: regras (`02` estrutura antiga tirada da cena e do catálogo), scripts da ponte, dumps de referência
  (`referencia/`), catálogo do plugin classificado (antiga × Grossl).
- Corrediças Fulterer FR 5045 / 5047 / 5046 ECD / 5210 OE ECD (telescópicas) e oculta UniHide Slowmotion FGVTN, feitas
  no modelo antigo (`componentes/corredicas_fulterer_unihide.md`), com minifotos.
- Gaveta HD Invisível da cena corrigida: `base_gaveta` lê `kit_corredica!diffbodyrail` (fórmula estava cortada), folga
  `2*(2.45-parent!thickness)` (24,5 mm até a face interna da lateral) e carro/pino a partir da lateral
  (`scripts/hd_invisivel_folga.rb`).

## Pendente
- Fulterer/UniHide: confirmar qual tabela de furos vai em cada Fulterer (hoje 40 kg na 5045, 60 kg nas outras),
  furos da gaveta da 5047/5046 (aproximados), códigos `CM_KIT_COR_FULTERER_*` / `CM_KIT_COR_OCU_FGVTN_UNIHIDE_*`
  (provisórios); carga da FR 5045.
- HD Invisível: confirmar a folga pelo manual da própria HD (foi usado o da UniHide). Mesmo erro de fórmula pode
  estar em outros moldes antigos de gaveta (procure `kit_corredica!diffbody` sem `rail`).
- Conferir no catálogo quais componentes são mesmo da biblioteca antiga (a separação de `referencia/catalogo_plugin.md`
  é por nome/código) e completar `regras/02` com balcão, portas e prateleiras quando forem usados.
- `upmtool` do minifix/cavilha nos moldes antigos não conferidos.
- Repositório git local criado sem commit e sem remoto: pedir ok para o 1º commit e se quer remoto no GitHub.

## Cena aberta por último
`G:\Meu Drive\corrediças_sabin.skp`: `conteiner` (gaveta HD Invisível, já corrigida) e `conteiner#12` (Häfele H45 S)
originais; ao lado (x +700…) `conteiner_gaveta_fulterer_fr5045/_fr5047/_fr5046_ecd/_fr5210_oe_ecd` e
`conteiner_gaveta_fgvtn_unihide_slowmotion`. O usuário pôs também 6 `balcao` e um `armario_alto_obliquo` (y −5932 /
−7367). Arquivo não salvo pela sessão. Confira sempre pela ponte: a cena muda entre sessões.

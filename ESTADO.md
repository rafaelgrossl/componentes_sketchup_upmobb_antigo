# Estado atual (atualize ao fim de cada sessão)

Última atualização: 23/10/2026 (tarde: corrediças refeitas pelos manuais, no SketchUp 2027).

## Feito
- Pasta criada: regras (`02` estrutura antiga tirada da cena e do catálogo), scripts da ponte, dumps de referência
  (`referencia/`), catálogo do plugin classificado (antiga × Grossl). Repositório no GitHub
  (`rafaelgrossl/componentes_sketchup_upmobb_antigo`, branch `main`).
- Corrediças Fulterer FR 5045 / 5047 / 5046 ECD / 5210 OE ECD (telescópicas), ocultas Fulterer 40 kg / 60 kg
  (amortecedor) e oculta UniHide Slowmotion FGVTN (`componentes/corredicas_fulterer_unihide.md`), com minifotos.
  Conferidas com os desenhos de 250 a 700: furos do móvel = ø6,2 do sistema 32 (antes usavam a tabela da oculta),
  furos da gaveta da 5047/5046 corrigidos (o 0 do desenho fica atrás da ponta), pino traseiro da UniHide com broca
  f_7mm (altura já estava certa: 38 mm da base da corrediça).
- Gaveta HD Invisível da cena corrigida: `base_gaveta` lê `kit_corredica!diffbodyrail` (fórmula estava cortada), folga
  `2*(2.45-parent!thickness)` (24,5 mm até a face interna da lateral) e carro/pino a partir da lateral
  (`scripts/hd_invisivel_folga.rb`).
- `ponte.sh` escolhe a ponte do SketchUp (2026/2027) que estiver ligada.

## Pendente
- Ocultas Fulterer 40/60 kg: modelo/código de fábrica e manual (folga, carro e pino copiados da UniHide);
  `itemcode` `CM_KIT_COR_OCU_FULTERER_*`, `CM_KIT_COR_FULTERER_*` e `CM_KIT_COR_OCU_FGVTN_UNIHIDE_*` provisórios;
  carga da FR 5045.
- Manuais: `FR_5047.0600_mm.pdf` traz o desenho de 650; falta o da 5047 de 350 (usado o da 5045).
- HD Invisível original (`conteiner`): pino traseiro ainda com f_5mm (a UniHide pede ø7; mesma família?). Confirmar a
  folga pelo manual da própria HD. Mesmo erro de fórmula pode estar em outros moldes antigos de gaveta (procure
  `kit_corredica!diffbody` sem `rail`).
- Conferir no catálogo quais componentes são mesmo da biblioteca antiga (a separação de `referencia/catalogo_plugin.md`
  é por nome/código) e completar `regras/02` com balcão, portas e prateleiras quando forem usados.
- `upmtool` do minifix/cavilha nos moldes antigos não conferidos.

## Cena aberta por último
`G:\Meu Drive\corrediças_sabin.skp` no **SketchUp 2027**: `conteiner` (gaveta HD Invisível) e `conteiner#12` (Häfele
H45 S) originais; ao lado (x +700…+2800 do `conteiner#12`) `conteiner_gaveta_fulterer_fr5045/_fr5047/_fr5046_ecd/
_fr5210_oe_ecd`; do `conteiner` (x +700/+1400/+2100) `conteiner_gaveta_fgvtn_unihide_slowmotion` e
`conteiner_gaveta_fulterer_oculta_40kg/_60kg`. Arquivo não salvo pela sessão. Confira sempre pela ponte.

## Sugestões (revisão)
- Antes de usar uma tabela de furos, pergunte de qual ferragem ela é (a da oculta foi parar nas telescópicas).
- Desenho com o 0 deslocado da ponta: conferir se os furos caem no sistema 32 (`regras/04`).
- `corredicas_fulterer_testes.rb` mede da ponta do perfil (bounds): trocar pela frente do móvel, como o `confere`.

# Referência (biblioteca antiga)

Arquivos grandes: **procure com Grep**, não leia inteiros. Formato dos dumps (`scripts/dump_produto.rb`): uma linha por
componente/grupo (`C`/`G` definição [`_name`] medidas mm @posição no mundo), e abaixo as chaves `D` (definição) e `I`
(instância), sem o ruído (`_error`, `_label`, `_nominal`...). Definição repetida aparece uma vez só.

| Arquivo | O que é |
|---|---|
| `dump_gaveta_hd_invisivel.txt` | `conteiner` da cena: gaveta com a oculta HD Invisível (já com a folga corrigida em 23/10) |
| `dump_gaveta_hafele_h45.txt` | `conteiner#12` da cena: gaveta com a telescópica Häfele H45 S |
| `dump_balcao_cm_bal.txt` | `balcao#1` da cena: balcão CM_BAL com caixa_balcao e porta dupla Arezzo |
| `dump_armario_alto_obliquo.txt` | `armario_alto_obliquo` da cena (CM_AR_ALT_CAN_OBL) |
| `estudo_catalogo.txt` | moldes do catálogo (`scripts/estuda_catalogo.rb`, 3 níveis, campos): caixa_balcao, balcao_com_tampo, conjunto_gavetas_2und, prateleira_1und, porta_de_giro_sem_puxdor, kit_corredica_invisivel_generica, corredica_tn_telescopica_normal, divisoria_1und, frente_gaveta |
| `catalogo_plugin.md` | todos os moldes do catálogo do plugin, separados antiga × Grossl (`scripts/catalogo_plugin.rb` refaz) |

Refazer um dump: ajuste `ALVO` em `scripts/dump_produto.rb` e envie pela ponte (sai em `%TEMP%`).

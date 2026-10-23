# 01 · Fundamentos

O Upmobb não desenha: ele **lê os atributos** dos componentes dinâmicos (dicionário `dynamic_attributes`)
e gera lista de corte, fitas, usinagens, orçamento e exportação. Componente "funciona" quando os atributos
certos estão nos lugares certos, com as fórmulas certas.

## Eixos
Origem no canto **traseiro-esquerdo-inferior**. X → direita, **Y cresce para trás** (a frente fica em
`y = -leny`), Z → cima. Peças e chapas ficam em `y = -parent!leny` e crescem +Y.

## Unidades
| Onde | Unidade |
|---|---|
| `lenx`, `x`, `mx`, `px`... gravados no dicionário | polegada |
| fórmulas (`_lengthunits` = CENTIMETERS) | centímetro |
| campos do usuário (`_units` MILLIMETERS) | milímetro |
| `thickness` | texto em cm: `"1.85"` = 18,5 mm (opções `&15mm=1.55&18mm=1.85&25mm=2.55&`) |
| `upmcut*`, `upmlength/width/height/depth`, furos, usinagens | mm (fórmula `*10`) |
| `upmquantity` | chapa m² · fita e usinagem linear: metro |

Valores quase sempre **texto**: `"1"` e não `1`. A janela de edição do Upmobb grava medidas como texto em polegada.

## Onde gravar
- **Componente:** definição E instância. O motor lê a definição; a instância sobrescreve. Chaves auxiliares
  (`_x_label`, `_x_access`, `_x_formlabel`, `_x_options`, `_x_units`, `_x_formulaunits`) só na definição.
- Fórmulas de posição/rotação: `_inst__x_formula` (definição) + `_x_formula` (instância). Filhos aninhados
  costumam ter a fórmula na instância: gravar só na definição não muda nada.
- **Grupo:** só no próprio grupo (usinagens costumam ser grupos). Cópias de grupo dividem a definição:
  escreva na instância de cada grupo. `make_unique` renomeia para "Grupo#N".
- Rebaixo/fresagem são lidos na **definição**; furo na **instância**.

## Fórmulas
- `parent!chave` lê o pai; `Nome!chave` lê um irmão pelo `_name` (ex.: `Borda Frontal!upmcode`,
  `Chapa de MDF!upmcutliquidlength`). Neto não lê o avô: o filho do meio repassa (`thickness = parent!thickness`).
- Sem `=` no início; texto entre aspas duplas; concatenação com `&`. Funções: `if, and, or, not, choose,
  abs, round, floor(x,passo), ceiling(x,passo), largest, smallest, sqrt, sin, cos, lower, upper, proper,
  substitute, len`. Não existem `max()`/`min()`: use `largest()`/`smallest()`.
- Funções do Upmobb: `upmaccess("campo|0|LIST")` mostra/esconde campo; `upmchangeatt(nome,valor,exibe)`;
  `upm_set_name(...)`; `upmgetid()`; `upmgetrootname()`.

## Campo editável (janela de opções)
```
_x_access     = TEXTBOX | LIST | NONE (oculto)    (nunca VIEW: ou edita ou não aparece)
_x_formlabel  = "Rótulo:"          _x_label = "x"
_x_options    = "&Rótulo=valor&Outro=valor&"        (LIST; grava o valor da direita)
_x_units      = MILLIMETERS (medida) | STRING (texto/lista)
_x_formulaunits = CENTIMETERS (medida) | STRING
```
Campo com `_x_formula` é recalculado a cada redesenho: para ser variável editável, **sem fórmula**.

## Motor de DC (SketchUp)
- `dcc = $dc_observers.get_latest_class`; redesenhar: `dcc.redraw_with_undo(produto)` (ou
  `dcc.redraw(produto, false)` dentro de um teste).
- Redimensionar instância: `dcc.set_forced_config_value(inst, "lenx", polegadas)` + redraw. No produto com
  fórmula fixa (`_lenx_formula = "80.0"`) isso não basta: grave `_lenx_formula` (cm) e `lenx` (pol) na
  instância e na definição.
- Tamanho nominal: no 1º redraw o DC guarda o tamanho da geometria (`_lenx_nominal`). Crie a geometria no
  tamanho real, nunca numa caixa de 1 cm.
- Apagar definições: de cima para baixo (pai primeiro), repetindo até não sobrar sem uso.

## Cuidados do Upmobb
- `type` é lido por "contém" (`"conteiner_internal|peace"`).
- `upmdisable = "1"` desliga o elemento e tudo abaixo dele (corte, usinagem, exportação). `hidden = upmdisable`.
- Toda chave `upm*` vai para orçamento/ERP: não invente.
- Na troca de modelo a instância perde tudo menos `x, y, z, rotx, roty, rotz`; o que deve sobreviver vai em `atttransfer`.
- O Upmobb é criptografado (`.rbe`, `.upm`) e tem classes congeladas: não ler nem contornar.

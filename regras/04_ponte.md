# 04 · Ponte com o SketchUp

O SketchUp precisa estar aberto com a ponte ligada: Extensões > Componentes Upmobb > Ponte com o Claude.

Estas armadilhas vieram das duas bibliotecas (valem para todo DC). Scripts citados que não estão em `scripts/`
(`ro82_*`, `ro27_*`, `ro65_*`, `corredicas_tt44ot_tnh45.rb`...) ficam em `..\upmobb_componentes\scripts\` (Grossl, só consulta).

## Enviar um comando
**Atalho (com ou sem Ruby):** `bash scripts/ponte.sh arquivo.rb [segundos]`, `bash scripts/ponte.sh -e "codigo"`,
`bash scripts/ponte.sh --estado`: imprime só a saída e o erro.

```bash
ruby "$APPDATA/SketchUp/SketchUp 2026/SketchUp/Plugins/componentes_upmobb/ponte/enviar.rb" -e "codigo" [segundos]
ruby "$APPDATA/SketchUp/SketchUp 2026/SketchUp/Plugins/componentes_upmobb/ponte/enviar.rb" arquivo.rb [segundos]
```
- Sem Ruby na máquina: `powershell -NoProfile -ExecutionPolicy Bypass -File "<plugin>/ponte/enviar.ps1" ...`.
- Saída: JSON `{ ok, resultado, saida, erro, linhas_erro, segundos }`. Código 0 ok, 1 erro, 2 tempo esgotado
  (SketchUp fechado ou ponte desligada). `--estado` mostra se a ponte está ligada.
- Comandos maiores: escreva o `.rb` em `scripts/` (ou no scratchpad) e envie o arquivo.

## Dentro do comando
- Atalhos: `model`, `sel`, `ents`, `mm(valor_mm)` → polegadas, `foto(ent)`, `projeto`, `dc(ent, chave)`.
- Cada comando roda numa operação: erro desfaz tudo; Ctrl+Z desfaz o comando.
- **Testar sem alterar:** faça a mudança, meça e termine com `raise "resultado: ..."` — a ponte desfaz e o
  texto volta em `erro`.
- Mede em mm: `->(v){ (v.to_f*25.4).round(1) }`. Bounds de um filho no mundo: transforme os 8 cantos de
  `definition.bounds` por `pai.transformation * filho.transformation`.

## Armadilhas (já aconteceram)
- `AttributeDictionary#each_pair` sem bloco dá LocalJumpError: use `d.keys.each { |k| d[k] }`.
- `x = algo or next` é erro de sintaxe dentro de bloco: use `next unless x`.
- `next` no nível de cima do comando não funciona: use if/else.
- `python` não existe nesta máquina: para ler o JSON use `ruby -rjson -e`.
- No bash, `$TEMP` funciona para arquivos temporários (o `/tmp` do bash não é o mesmo do Ruby).
- Achar o produto pelo nome da definição (`balcao#2`), não pelo `name`.
- **Teste com `raise`: use `dcc.redraw(prod, false)`, nunca `redraw_with_undo`**: ele abre operação própria e
  o `raise` não desfaz o que veio antes (a mudança fica gravada). Mesmo com `redraw(false)` já sobrou valor
  de teste gravado uma vez: **depois de um teste, confira a cena** (valores que o teste mexeu).
- Imagem para conferir: troque `view.camera`, `view.write_image(filename:, width:, height:)` e volte a câmera.
  Desligue o raio-X (`model.rendering_options['ModelTransparency'] = false`) e esconda o que atrapalha dentro de
  um comando com `raise`. Pintar uma face de cor forte nesse teste mostra o que é geometria real e o que é truque.
- **Antes de rodar:** feche a edição do usuário (`model.close_active` enquanto houver `model.active_path`):
  dentro da edição as transformações vêm erradas e as imagens saem vazias. E olhe a árvore de novo: o usuário
  pode ter trocado o modelo no meio do trabalho.
- Atributo numérico: grave `Float` (`.to_f`), nunca `Length` (ex.: `bounds.width`): o redesenho quebra com
  "comparison of Length with nil".
- Câmera: guarde uma **cópia** (`Sketchup::Camera.new(c.eye, c.target, c.up)`), não `view.camera`, e
  câmera não volta com o `raise`.
- Trocar a definição de um filho: o redesenho pode não reposicionar quem já tinha `y` guardado. Posicione
  direto (mesmo valor da fórmula) e meça.
- `_hidden_formula` só funciona se o atributo `hidden` existir (grave `hidden` = 1 junto).
- Fórmula DC não aceita texto vazio `""` (dá "CONTAGEM DE PARÊNTESES"): use dois ramos no `if`.
- Ferramenta sem Ruby: `enviar.ps1 arquivo.rb -Segundos 120` (o tempo é parâmetro nomeado).
- No `ruby -e` do bash, texto com acento quebra (CP850): edite com a ferramenta de edição ou num `.rb`.

## Padrões de código
```ruby
DA = 'dynamic_attributes'
filho = ->(pai, nome) { pai.definition.entities.find { |e| e.respond_to?(:definition) && e.definition.name == nome } }
# copiar um conjunto/peça
n = pai.definition.entities.add_instance(src.definition, src.transformation)
d = src.attribute_dictionary(DA); d.keys.each { |k| n.set_attribute(DA, k, d[k]) }
n.make_unique; n.definition.entities.grep(Sketchup::ComponentInstance).each(&:make_unique)
n.definition.name = model.definitions.unique_name('nome_novo')
# formula de posicao/rotacao (definicao + instancia)
pf = ->(c, k, v) { c.definition.set_attribute(DA, "_inst__#{k}_formula", v); c.set_attribute(DA, "_#{k}_formula", v) }
# redesenhar o produto
$dc_observers.get_latest_class.redraw_with_undo(produto)
```
Copiar um produto inteiro (ex.: gaveta de teste): `make_unique` recursivo em todos os níveis (`scripts/corredicas_tt44ot_tnh45.rb`,
lambda `uniq`); pule definições que devem continuar compartilhadas (ex.: `nome_fgv`).
Rotação de peça: descubra testando candidatos e medindo (`scripts/sonda_rotacao.rb`), não de cabeça.
- `rendering_options['ModelTransparency']` é o **raio-X**, não a transparência dos materiais: deixe `false` nas fotos.
- Componente com `x = px` (fórmula) solto no nível de cima volta para 0 no redesenho: para enfileirar, ponha
  cada um num grupo e mova o grupo.
- **Ordem de cálculo do DC = alfabética** (não por dependência): atributo calculado que usa outro precisa vir depois
  no alfabeto (prefixos `a01…`, `a02…`). Senão usa o valor velho e o resultado só acerta no 2º redesenho.
- Duas constantes seguidas numa fórmula (`-5-9.3`) dão conta errada: junte (`-14.3`).
- **Redesenho lento abre uma caixa modal do DC** ("Parece que esta operação está demorando bastante. Deseja
  continuar? Sim/Não") e o redesenho **para esperando um clique** — pela ponte parece travado (> 10 min), e o timer
  da ponte continua rodando por dentro da caixa (caixas se empilham). Aparece no `redraw_with_undo` (o que o Upmobb
  usa) quando passa de ~10 s; o `redraw(p, false)` não abre. Meta: produto redesenhar com desfazer em < 8 s.
  Ver as caixas: listar janelas do SketchUp por UI Automation (PowerShell); responder pelo botão Sim/Não.
- O que deixa o redesenho lento: muitos nós DC (peça composta = ~360 nós cada) **aninhados fundo** (composta dentro
  de um subconjunto dentro do produto ficou muito pior que no produto direto). Ponha peças compostas direto no
  produto; corte variantes ocultas e o máximo de repetições (Sequenziato ficou em 3 portas).
- **Produto com `lenx/leny/lenz` por fórmula é escalado pelo DC** quando a medida muda e o conteúdo não enche essa
  caixa (porta + trilho que passa do vão): tudo dentro fica esticado/achatado. Produto que não é caixa: use campos
  com outro nome (`vaox`, `vaoz`) e nenhum `lenx/leny/lenz`.
- Filho sem nenhuma fórmula própria na definição não é processado pelo DC (fica na origem): dê pelo menos uma.
- **Posição por fórmula que aparece na janela de atributos**: além de `_inst__x_formula` / `_x_formula`, grave o
  rótulo `_x_label = "X"` (também `_rotx_label`, `_lenx_label`…) **na definição** (o DC apaga `_inst__x_label`) e
  crie a chave do valor (`_inst_x` na definição, `x` na instância, Float). Sem a chave o DC nunca grava a posição
  real e o campo fica vazio. Cópias geradas pelo DC (`copies`) perdem o rótulo a cada redesenho.
- **Fórmulas com o mesmo texto no mesmo componente**: o DC reaproveita o resultado da primeira, já convertido.
  `a3_thickness` (cm, vira polegada) e `totalthickness` (número) com a mesma soma deixaram `totalthickness =
  1,4567` e a composta inteira com 14,6 mm. Escreva diferente: `(soma)`, `soma+0`.
- Cor fixa de ferragem: ponha o material **só na instância** (`inst.material`). O atributo DC `material` faz o DC
  repintar a cada redesenho: no Sequenziato (~95 peças) o redesenho com desfazer foi de ~10 s para 288 s.
- Redesenhos com desfazer seguidos de um produto pesado ficam cada vez mais lentos (memória e histórico de
  desfazer do SketchUp: 10 s → 29 s → 94 s na mesma cena). Meça o tempo logo depois de abrir o SketchUp.
- Definição com subcomponentes DC (ex.: folha) usada por várias instâncias irmãs: o DC duplica tudo a cada
  redesenho (vaza definições). Dê a cada uma a sua (`make_unique` profundo).
- **Trocar a geometria dentro de um filho DC com `lenx/leny/lenz`** (ex.: roldana do molde): o DC escala pelo
  `_last_lenx/y/z` antigo (dicionário **sem nome** `''` na instância) e estica a geometria nova. Depois de trocar,
  grave `lenx/leny/lenz` (def e instância) e `_last_len*` (dicionário `''`) com a medida nova e a geometria com
  `IDENTITY` (`scripts/ro27_carros.rb`).
- Geometria nova (ferragem sem 3D): modele no Blender (`<plugin>/banco/blender/<nome>/modelo.py`) e rode com
  **`bash scripts/blender.sh <nome>`** (o `blender(...)` pela ponte foi interrompido no meio das prévias: `^C` no
  blender.log, sem resultado.json). Prévia vista de trás/sem suavizar: `bpy.ops.wm.obj_import` + câmera própria.
  Cortador de booleana: apague depois (senão vai junto no .obj). Pela ponte também dá:
  `blender("banco/blender/<nome>/modelo.py")` e ler o `resultado.json`. A origem do .obj é mantida. Para virar
  definição sem a escala do import: `g = obj(caminho)`, `d.entities.add_instance(g.definition, g.transformation).explode`,
  `g.erase!` (ver `ro27_produto.rb`).
- Geometria de fabricante pesada (STL: o carro RO-65 tinha 141 mil faces, sem arcos): meça os pontos-chave pelos
  vértices (`z` mínimo = roda, faixas de `y` por altura, furos pela imagem de frente com escala conhecida) e refaça
  simplificada no Blender (`scripts/ro65_produto.rb`, `componentes/porta_correr_ro65.md`). Original fica intacto.
- Imagem de corte/vista ortogonal ao longo de um eixo: **esconda todos os outros produtos** (`model.entities`), senão
  aparece tudo o que está na mesma linha (produtos enfileirados em x). Use os eixos do produto (`t.xaxis`).
- `scripts/pdf2png.ps1` precisa de caminhos Windows absolutos (`cygpath -w`); com caminho relativo sai PNG de 0 byte.
- Teste de desempenho: meça `redraw_with_undo` com o vigia (`scripts/vigia_dc.ps1 -Minutos 10 -Log arq`: responde Sim e anota) e grave o
  tempo num arquivo; lembre que `redraw_with_undo` grava o que veio antes no mesmo comando (o `raise` não desfaz).
- **Copiar o dicionário DC de um texto/logo** (para trocar por outro): leva o `_lengthunits` do molde (às vezes
  `INCHES`): a fórmula `2.0` (cm) virou 2 polegadas = 51 mm. Grave `_lengthunits = CENTIMETERS` na nova.
- Texto 3D plano novo colado na face do molde pisca (z-fighting): afaste 0,2 mm pela normal (`scripts/corredicas_fulterer_unihide.rb`, `troca_texto`).
- Furos (`Transfer Hole`) são **grupos** com definição `Grupo503`: o `arvore.rb` não mostra (PULA `Grupo`). E nem sempre
  ficam na peça óbvia: na oculta HD estão no lado (`corredica_esquerda`), não na base. Liste os grupos `name =~ /Hole/`.
- Apagar instância dentro de um `each` e depois testar `c.definition` dá "reference to deleted": use `if/elsif`.
- Refazer gavetas de teste: `scripts/apaga_gavetas_teste.rb` apaga e remove só as definições que ficaram sem uso
  (não faz "purge" geral da cena do usuário).
- Manuais em PDF: `pdftotext -enc UTF-8 -layout arq.pdf -` (existe no Git Bash) dá as cotas em texto. O PNG do
  `pdf2png.ps1` sai **1,25× maior** que o `-Largura` pedido (escala do Windows): pegue o tamanho real da imagem antes
  de calcular o recorte.
- **Filho com `lenx/leny` por fórmula dentro de um componente que o DC escala** (carro da oculta, sem fórmula de
  tamanho própria): o DC para de escalar o pai e ele volta ao tamanho da definição (carro de 413 → 587 mm, saindo da
  gaveta). Texto/logo novo ali entra **sem dicionário DC** (como os do molde). Depois de mexer, compare a árvore com o
  molde (`scripts/compara_gavetas.rb`): o `bounds` de instância engana, meça pelos cantos.
- **Cota de manual: veja onde começa e termina a seta** (recorte a vista e amplie). Na UniHide "N − 49" e "24,5" vão
  até a face **interna** da lateral da gaveta, não a externa: folga por fora = 24,5 − espessura. Folga que depende
  da espessura vai por fórmula (`2*(2.45-parent!thickness)`), nunca fixa.

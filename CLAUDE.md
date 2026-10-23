# Componentes Upmobb — biblioteca ANTIGA (Upmobb)

Esta pasta é só para **criar e modificar componentes dinâmicos da biblioteca antiga do Upmobb** (a "biblioteca
Upmobb": códigos `CM_*`, `conjunto_gavetas_Nund` > `gaveta` > `base_gaveta` + `kit_corredica`...) na cena aberta do
SketchUp. A biblioteca nova (Grossl: `fix_*`, `pec_*`) é da pasta `Desktop\upmobb_componentes`: não misture.
Não altere o código do plugin `componentes_upmobb` (só leitura).

Idioma: português. Respostas curtas. Sem recapitular.

## Ao abrir a sessão
Leia `ESTADO.md` e confira pela ponte se o SketchUp está aberto (`bash scripts/ponte.sh --estado`).

## Antes de cada pedido (sempre)
1. Leia a regra do assunto em `regras/` (não leia tudo): fundamentos (`01`), **estrutura antiga** (`02`), receitas
   (`03`), ponte (`04`), nomes e códigos (`05`), minifotos (`06`).
2. Confirme que o componente é da biblioteca antiga (tabela em `regras/02`). Se for Grossl, avise e pare.
3. Olhe a cena pela ponte ANTES de propor: árvore (`scripts/arvore.rb`) e atributos (`scripts/atributos.rb`), ou o
   dump completo (`scripts/dump_produto.rb`). Nunca suponha a estrutura.
4. Procure um molde antigo parecido: na cena, nos dumps de `referencia/`, em `componentes/` ou no catálogo do plugin
   (`referencia/catalogo_plugin.md`; para ver um molde do catálogo sem mexer na cena: `scripts/estuda_catalogo.rb`).
   **Copie o molde.** Criar do zero é o último recurso.
5. Se o pedido for ambíguo ou apagar peças, mostre o plano em poucas linhas e pergunte. Senão, faça.

## Regras fixas
- Tudo por fórmula (`parent!`, irmãos pelo `_name`): nada de medida fixa que deveria acompanhar o módulo.
  Folga que depende de espessura vai por fórmula da espessura.
- Grave na **definição E na instância** (posição/rotação: `_inst__x_formula` na definição e `_x_formula` na instância).
- Unidades: valores em polegada no dicionário, fórmulas em cm, campos do usuário em mm, `upm*` de corte em mm,
  `thickness` texto em cm ("1.55"). Valores quase sempre TEXTO.
- `edge_*`: **1 = sem fita**.
- Campos editáveis: `_x_access` TEXTBOX/LIST, `_x_formlabel`, `_x_units` MILLIMETERS, `_x_formulaunits` CENTIMETERS.
  Campo com fórmula não é editável. **Nunca `VIEW`.**
- `name`/`description` sem caixa alta, `name` no singular. Referências pelo nome da definição; não troque `_name`
  que o pai lê (`kit_corredica`, `base_gaveta`...).
- Não invente códigos (`itemcode`/`upmcode`) nem atributos `upm*`. Reaproveite o do molde e avise. `upmtool` só com
  nome que existe na máquina.
- `parentrefresh` ("1".."3", na definição) quando o filho muda algo que o pai lê.
- Usinagem pelo **lado A** (z = lenz da Chapa). Usinagem só com rotação, nunca espelho.
- Copiar peça/conjunto: `add_instance` + copiar o dicionário da instância + `make_unique` (e dos filhos).
  Componente de teste novo: copie a gaveta/produto inteiro ao lado (ver `regras/03`).
- **Cota de manual: veja onde começa e termina a seta** (recorte e amplie a vista) antes de usar.
- Depois de mexer: redesenhe e **meça** (mm) e **compare com o molde** (`scripts/compara_gavetas.rb`). Teste variações
  dentro de um comando que termina com `raise` e depois confira a cena. Antes de rodar: feche a edição do usuário e
  olhe a árvore de novo (o usuário mexe na cena durante a sessão).
- Cada comando da ponte é uma operação: Ctrl+Z desfaz. Não salve o arquivo do usuário.

## Ao terminar um componente (e ao fim da sessão)
- Atualize `ESTADO.md` (feito / pendente / cena) e a ficha `componentes/<nome>.md` (o que é, estrutura, campos,
  fórmulas-chave, script).
- Minifoto em `minifotos/<categoria>/` (`regras/06`). Regra nova → `regras/` (curto).
- Commit só com ok do usuário (repositório local; sem remoto por enquanto).

## Revisão de evolução (sempre que terminar)
1. O que deu errado ou custou tentativas? → armadilha em `regras/04` ou regra no assunto.
2. O que se repetiu? → script parametrizado em `scripts/`.
3. As regras fixas continuam certas?
4. O componente ficou melhor que o molde? (medida fixa, campo, código inventado, nome, valor de teste que sobrou).
   Erro do molde antigo achado → anote em `regras/02` ("Erros conhecidos").
5. A ficha permite refazer sem olhar a cena?
Mostre em poucas linhas o que melhorou e registre as sugestões em `ESTADO.md`. Mudança na cena só com ok.

## Referências (só leitura)
- Plugin: `%APPDATA%\SketchUp\SketchUp 2026\SketchUp\Plugins\componentes_upmobb\`
  - Catálogo de moldes: `banco\componentes\upmobb\` (índice classificado em `referencia/catalogo_plugin.md`).
  - Manual de atributos: `banco\wiki\02_atributos\`; convenções gerais: `banco\wiki\01_upmobb\`.
  - `banco\wiki\03_receitas\` e `05_biblioteca\` descrevem na maior parte a biblioteca **Grossl** (`fix_*`): use só
    como apoio geral, nunca como molde.
- Manuais de ferragens: `G:\Meu Drive\ferragens manuais`.
- Pasta da Grossl (consulta): `Desktop\upmobb_componentes` (regras e scripts de lá valem só se não forem `fix_*`).

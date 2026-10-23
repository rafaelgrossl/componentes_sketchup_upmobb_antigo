# 06 · Minifotos (miniaturas dos componentes)

## Pasta `minifotos/`
Aqui ficam só as minifotos dos componentes feitos nesta pasta, os logos (`_logos/`) e
`gavetas_corredicas/corredica_telescopica.png` (de onde o `minifoto.ps1` copia o ícone). A coleção inteira (493 fotos
por categoria) está em `..\upmobb_componentes\minifotos\` (só consulta: não grave lá).
- Uma pasta por categoria: `modulos`, `pecas`, `caixas`, `tamponamentos_bases`, `agregados`, `acessorios`,
  `gavetas_corredicas`, `portas_frontais`, `puxadores_fechaduras`, `conjuntos_fixacao`, `dispositivos_fixacao`,
  `organizadores_gaveta`, `eletrica_fontes`, `led`, `espelhos_vidros`, `estruturas_metalicas`, `usinagens`, `insumos`.
- Nome do arquivo = título escrito na foto, minúsculo, sem acento, com `_` (`fonte_evo_24v_35w.png`).
  Título repetido na mesma pasta → `_2`. Cópias idênticas ficam em `_duplicadas/` (não apagadas).
- `indice.csv` (pasta;arquivo;titulo;original): liga cada nome ao arquivo original (hash da pasta "Dashboard").
  Foto nova → acrescente a linha.

## Padrão visual (o do usuário: miniaturas dele em `Documents\upmobb\*.jpg`, ex. `SLOWMOTIONET.jpg`)
- 400x400 JPG, perto de 60 KB (fundo branco comprime: na qualidade máxima fica ~40 KB, tudo bem).
- Título em CAIXA ALTA, **Gotham Bold Italic**, 27 px (letra ~19 px), uma linha a cada 25 px, a partir de y≈11,
  x≈18. **1ª linha preta, demais cinza (46,46,46).** Todas no mesmo tamanho; se não couber ao lado do ícone,
  quebre em mais linhas (ex.: `CORREDIÇA|TELESCÓPICA|TT44 SLOWMOTION`) em vez de diminuir a letra.
- Logo da marca **do produto** logo abaixo do título (`minifotos/_logos/`: `fgvtn.png` FGVTN, `rometal.png` Rometal, `hafele.png` Häfele, `fulterer.png` Fulterer
  — RO-82 e Sequenziato são Rometal, mesmo vendidos pela FGVTN) e a marca **não** vai no texto.
- Ícone azul no canto superior direito; foto real do produto embaixo, sem margem branca.

## Como fazer
1. Foto do produto: do manual em `G:\Meu Drive\ferragens manuais` (ou render da geometria oficial: `scripts/foto_componente.rb`,
   fundo branco, sem arestas, sem furos; ajuste ALVOS e VISTAS no topo; componente que não está solto na cena:
   ponha uma cópia num grupo dentro de um comando que termina com `raise`) →
   `powershell -File scripts/pdf2png.ps1 -Pdf manual.pdf -Png pagina.png` (1ª página, 2480 px de largura) e
   `scripts/recorte_imagem.ps1 -Img pagina.png -Saida foto.png -X -Y -W -H -Clarear 1.08` (fundo cinza da foto vira
   branco). Texto/selo da página dentro do recorte: `-Branco "x,y,w,h"`. Olhe o recorte: ponta cortada ou texto.
2. `powershell -File scripts/minifoto.ps1 -Foto foto.png -Titulo "LINHA 1|LINHA 2" -Logo minifotos/_logos/fgvtn.png -Saida minifotos/<pasta>/<nome>.jpg`
   (o script para se a Gotham não estiver instalada; corta a margem branca da foto; ícone copiado de uma minifoto).
   Logo de outra marca: recorte de uma miniatura do usuário com `scripts/logo_nitido.ps1` (amplia e deixa a borda
   nítida, cor chapada; ex. `_logos/hafele.png` saiu da minifoto da A30 GP2: `-X 12 -Y 51 -W 93 -H 19`). Recorte
   simples com `recorte_imagem.ps1` fica borrado quando a miniatura é pequena (256 px).
   Logo do selo de um desenho em PDF: `pdf2png.ps1 -Largura 9000` + `logo_nitido.ps1 -Escala 2` (`fulterer.png` saiu do
   `FR_5045.0450_mm.pdf`). Sem foto do produto: foto do 3D da cena (`scripts/foto_corredica_aberta.rb`, aberta, logo à vista).
   Fonte: a Gotham Bold Italic precisa estar instalada na máquina (o script para se não estiver).
   Foto enviada pelo usuário: guarde em `ferragens/fotos/` desta pasta (fora do git) para poder refazer.
3. Olhe a imagem antes de entregar.
4. Copie também para `Documents\upmobb\` com o **nome da definição**: `<definição do kit>.jpg`, ex. `corredica_fulterer_fr5045.jpg` (ao lado do
   `<definição>.skp`/`.png` que o plugin salva). Não sobrescreva o `.png` automático nem jpg existente.

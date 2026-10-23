# 03 · Receitas (biblioteca antiga)

## Corrediça nova a partir de um molde (feito: Fulterer FR 5045/5047/5046/5210, UniHide)
Script modelo: `scripts/corredicas_fulterer_unihide.rb` (ficha `componentes/corredicas_fulterer_unihide.md`).
1. Molde: telescópica → gaveta com `corredica_hafele_telescopica_normal`; oculta → gaveta com `kit_corredica_hd_invisivel`.
2. Copie a **gaveta inteira** (o `conteiner` do nível de cima) ao lado (x +700 mm) com `make_unique` recursivo e
   renomeie: `conteiner_gaveta_<marca>_<modelo>`; as definições do kit ganham `_<modelo>` no fim. Para refazer:
   `scripts/apaga_gavetas_teste.rb` (apaga e remove só as definições que ficaram sem uso).
3. No kit: `description`, `itemcode` (provisório, avise), `codfabricante` (do manual), `lenz` (altura do manual),
   `diffbodyrail` (folga do manual), `upmwidth`, `minlength/maxlength` + `keyalert` + `summary` com o alerta.
   `keyalert` é calculado antes de `summary` (ordem alfabética): use `parent!leny` (comprimento) nele.
4. Furos: 3 no móvel, `y` da frente do perfil por tabela de comprimento (`tab` no script: `if(L<meio,v1,if(...))`).
   Meça em mm da frente do móvel (`scripts/corredicas_fulterer_confere.rb`) e teste 270–600 (`..._testes.rb`, desfeito).
5. Folga da gaveta pelo manual, **por fórmula da espessura** se a cota for até a face interna:
   `diffbodyrail = 2*(2.45-parent!thickness)` (UniHide/HD). Confira a `base_gaveta` lendo `kit_corredica!diffbodyrail`.
6. Perfil da gaveta (oculta) a partir da face interna da lateral: carro `2.45+0.1`, pino/furo traseiro `2.45+0.7`,
   rebaixo `2.45+0.3` (direita negativo). A base (`BaseCorredicaOculta`) segue o comprimento: `parent!leny-1`.
7. Logo/marca: texto 3D plano (`add_3d_text`, extrusão 0, preenchido, com arestas), material próprio, 0,2 mm fora da
   face. Na telescópica (dentro de `trilho_interno`) com `lenx/leny` por fórmula e `_lengthunits = CENTIMETERS`; no
   carro da oculta **sem** dicionário DC (senão o carro para de escalar). Ver `troca_texto` / `troca_texto_plano`.
8. Compare com o molde peça a peça (`scripts/compara_gavetas.rb`) e tire imagem (corrediça aberta:
   `scripts/foto_corredica_aberta.rb`).
9. Minifoto (`regras/06`) e ficha em `componentes/`.

## Ler o manual da ferragem
- Manuais: `G:\Meu Drive\ferragens manuais` (e `..\upmobb_componentes\ferragens\manuais`, cópia local, fora do git).
- Texto: `pdftotext -enc UTF-8 -layout arq.pdf -`. Desenho: `scripts/pdf2png.ps1` (sai 1,25× maior que `-Largura`)
  e `scripts/recorte_imagem.ps1` para ampliar a vista. **Veja onde começa e termina cada seta** antes de usar a cota.
- Tabela de furos passada pelo usuário manda sobre o manual (pergunte qual vale para cada modelo).

## Peça e chapa (antiga)
`a1_height` / `a2_length` (ou `a2_width`) / `a3_thickness`; `lenx = if(a2_length>max_length,max_length,if(a2_length<min_length,min_length,a2_length))`,
`lenz` idem com `a1_height`; `edge_*` (1 = sem fita); `lamination = if(soma edges=4,'',"_LAM")`; `upmtextaggregates`;
`mx/my/mz`, `addx/addz` editáveis; `zobservation`. Chapa de MDF e bordas como em `regras/01`.
Para mexer numa peça, copie a fórmula da peça irmã do mesmo molde (dumps em `referencia/`).

# Cria as gavetas de teste das corredicas Fulterer (FR 5045, FR 5047, FR 5046 ECD, FR 5210 OE ECD) e da
# oculta UniHide Slowmotion (FGVTN), copiando os moldes da cena corredicas_sabin.skp:
#  - Fulterer: copia de conteiner#12 (telescopica Hafele H45 S, kit corredica_hafele_telescopica_normal).
#  - UniHide: copia de conteiner (oculta HD Invisivel FGVTN, kit kit_corredica_hd_invisivel).
# Telescopicas (desenhos Fulterer): furos do movel = furos 6,2 do sistema 32 (frente 35, meio 99 ou 259, ultimo 6,2
# do perfil), em mm do inicio do perfil (o perfil fica 2 mm atras da frente do movel). Furos da gaveta = rasgo da
# frente (32), do meio e de tras, do inicio do perfil (5047/5046: o 0 do desenho fica 3,2 / 1,8 atras da ponta).
# Ocultas Fulterer 40 kg / 60 kg (sem manual): copia da UniHide, furos do movel pela tabela do usuario
# (da frente do movel, ja com a folga de 2 mm: 37/69/ultimo). UniHide: 37, 69 e 37+E do manual.
# Logos: texto 3D plano (sem extrusao), com arestas: "Fulterer" (vermelho) e o modelo no lugar do logo Hafele e do
# "Normal"; na UniHide fica o logo FGVTN do molde e "Soft Closing" vira "UniHide".
while model.active_path; model.close_active; end
DA = 'dynamic_attributes'
dcc = $dc_observers.get_latest_class
top = ->(n) { model.entities.grep(Sketchup::ComponentInstance).find { |e| e.definition.name == n } or raise "#{n} nao existe" }
SRC_TEL = top.('conteiner#12')
SRC_OCU = top.('conteiner')

busca = lambda do |inst, re|
  return inst if inst.definition.name =~ re
  inst.definition.entities.grep(Sketchup::ComponentInstance).each { |c| r = busca.(c, re); return r if r }
  nil
end
copia = lambda do |src, dx_mm, nome|
  t = Geom::Transformation.translation([mm(dx_mm), 0, 0]) * src.transformation
  n = model.entities.add_instance(src.definition, t)
  d = src.attribute_dictionary(DA); d.keys.each { |k| n.set_attribute(DA, k, d[k]) }
  mu = ->(i) { i.make_unique; i.definition.entities.grep(Sketchup::ComponentInstance).each { |c| mu.(c) } }
  mu.(n)
  n.definition.name = model.definitions.unique_name("conteiner_gaveta_#{nome}")
  n
end
renomeia = lambda do |inst, suf|   # definicoes do kit: <nome sem #n>_<suf>
  inst.definition.name = model.definitions.unique_name("#{inst.definition.name.sub(/#\d+\z/, '')}_#{suf}")
  inst.definition.entities.grep(Sketchup::ComponentInstance).each { |c| renomeia.(c, suf) }
end
filhos = ->(i) { i.definition.entities.grep(Sketchup::ComponentInstance) }
seta = ->(o, k, v) { o.definition.set_attribute(DA, k, v); o.set_attribute(DA, k, v) }
formula = ->(o, k, v) { o.definition.set_attribute(DA, "_#{k}_formula", v); o.set_attribute(DA, "_#{k}_formula", v) }
furos = ->(i) { i.definition.entities.grep(Sketchup::Group).select { |g| g.name =~ /Hole/ } }
# tabela {comprimento cm => valor cm} -> if(L<meio, v1, if(...)) (fora da tabela = vizinho mais perto)
tab = lambda do |h, var = 'parent!leny'|
  ks = h.keys.sort
  expr = h[ks.last].to_s
  ks[0..-2].each_with_index.to_a.reverse.each { |k, i| expr = "if(#{var}<#{((k + ks[i + 1]) / 2.0).round(2)},#{h[k]},#{expr})" }
  expr
end
cor = lambda do |nome, rgb|
  model.materials[nome] || model.materials.add(nome).tap { |m| m.color = Sketchup::Color.new(*rgb) }
end
texto = lambda do |nome, txt, alt_mm, mat|
  d = model.definitions[nome]
  return d if d
  d = model.definitions.add(nome)
  d.entities.add_3d_text(txt, TextAlignLeft, 'Arial', true, true, mm(alt_mm), 0.0, 0.0, true, 0.0)
  d.entities.grep(Sketchup::Face).each { |f| f.material = mat; f.back_material = mat }
  d
end
# troca a instancia velha (texto/logo DC) por uma do texto novo, mesma posicao, sem escala
troca_texto = lambda do |velha, d_nova|
  pai = velha.parent
  tr = velha.transformation
  sai = tr.zaxis.normalize; sai.length = mm(0.2)   # 0,2 mm fora da face (colado ele pisca com ela)
  t = Geom::Transformation.axes(tr.origin.offset(sai), tr.xaxis.normalize, tr.yaxis.normalize, tr.zaxis.normalize)
  n = pai.entities.add_instance(d_nova, t)
  dv = velha.definition.attribute_dictionary(DA)
  dv.keys.each { |k| d_nova.set_attribute(DA, k, dv[k]) } if dv && !d_nova.attribute_dictionary(DA)
  iv = velha.attribute_dictionary(DA)
  iv.keys.each { |k| n.set_attribute(DA, k, iv[k]) } if iv
  b = d_nova.bounds
  seta.(n, '_name', d_nova.name)
  seta.(n, '_lengthunits', 'CENTIMETERS')   # o molde podia estar em INCHES (formula 2.0 virava 51 mm)
  formula.(n, 'lenx', (b.width.to_f * 2.54).round(4).to_s)
  formula.(n, 'leny', (b.height.to_f * 2.54).round(4).to_s)
  formula.(n, 'lenz', '0')
  %w[lenx leny].each { |k| seta.(n, k, k == 'lenx' ? b.width.to_f : b.height.to_f) }
  velha.erase!
  n
end
# no carro da oculta (escalado pelo DC, sem formula de tamanho): filho com lenx/leny faz o DC parar de escalar o
# carro (ficou com 587 mm em vez de 413). Texto entra SEM DC, com a escala do carro compensada nos eixos (como no molde).
troca_texto_plano = lambda do |velha, d_nova, carro|
  b = carro.definition.bounds
  esc = [carro.get_attribute(DA, 'lenx').to_f / b.width, carro.get_attribute(DA, 'leny').to_f / b.height,
         carro.get_attribute(DA, 'lenz').to_f / b.depth]
  comp = ->(v) { u = v.normalize; f = Math.sqrt((u.x * esc[0])**2 + (u.y * esc[1])**2 + (u.z * esc[2])**2); u.length = 1.0 / f; u }
  tr = velha.transformation
  sai = tr.zaxis.normalize; sai.length = mm(0.2) / esc[0]   # 0,2 mm fora da face (normal = x do carro)
  o = tr.origin.offset(sai); xa, ya, za = comp.(tr.xaxis), comp.(tr.yaxis), comp.(tr.zaxis)
  t = Geom::Transformation.new([xa.x, xa.y, xa.z, 0, ya.x, ya.y, ya.z, 0, za.x, za.y, za.z, 0, o.x, o.y, o.z, 1])   # axes() normaliza
  n = carro.definition.entities.add_instance(d_nova, t)
  velha.erase!
  n
end

# ---------------- Fulterer ----------------
# ultimo furo 6,2 do perfil do movel (cm do inicio do perfil). 5047 = 5045 (sem desenho de 350; o de 600 veio com 650).
C5045 = { 25 => 19.5, 30 => 22.7, 35 => 25.9, 40 => 35.5, 45 => 38.7, 50 => 45.1, 55 => 48.3, 60 => 51.5, 65 => 57.9, 70 => 61.1 }
C5046 = { 25 => 9.9, 30 => 9.9, 35 => 16.3, 40 => 19.5, 45 => 25.9, 50 => 29.1, 55 => 35.5, 60 => 38.7, 65 => 45.1, 70 => 48.3 }
C5210 = { 40 => 19.5, 45 => 25.9, 50 => 29.1, 55 => 35.5, 60 => 38.7, 65 => 45.1, 70 => 45.1 }
# furo do meio: 259 se o ultimo passa de 291, senao 99 (5046 250: 7 / 300: 67, os 6,2 que existem)
meio = ->(c, extra = {}) { c.to_h { |l, v| [l, extra[l] || (v > 29.1 ? 25.9 : 9.9)] } }
G5045 = { 25 => [3.2, 6.4, 19.2], 30 => [3.2, 6.4, 22.4], 35 => [3.2, 12.8, 28.8], 40 => [3.2, 16, 32], 45 => [3.2, 19.2, 38.4],
          50 => [3.2, 22.4, 44.8], 55 => [3.2, 25.6, 48], 60 => [3.2, 25.6, 54.4], 65 => [3.2, 28.8, 57.6], 70 => [3.2, 28.8, 64] }
G5210 = { 40 => [3.2, 12.8, 32], 45 => [3.2, 16, 35.2], 50 => [3.2, 16, 38.4], 55 => [3.2, 20.8, 44.8], 60 => [3.2, 24, 48],
          65 => [3.2, 22.4, 54.4], 70 => [3.2, 25.6, 57.6] }
# 5046: furos do desenho + 1,8 (o 0 fica 1,8 atras da ponta); de tras = 1o rasgo do grupo de tras ou o redondo 4,5
G5046 = { 25 => [3.2, 6.4, 16.3], 30 => [3.2, 6.4, 21.3], 35 => [3.2, 16, 26.3], 40 => [3.2, 19.2, 29.3], 45 => [3.2, 19.2, 34.3],
          50 => [3.2, 22.4, 36.8], 55 => [3.2, 25.6, 41.6], 60 => [3.2, 28.8, 46.4], 65 => [3.2, 28.8, 49.6], 70 => [3.2, 32, 56] }
VERMELHO = cor.('Fulterer - Logo', [226, 0, 26])
CINZA = cor.('Corredica - Texto', [60, 60, 60])
VERDE = cor.('FGVTN - Logo', [122, 193, 67])
LOGO_FUL = texto.('logo_fulterer', 'Fulterer', 6, VERMELHO)

FUL = [
  { suf: 'fulterer_fr5045', mod: 'FR 5045', cod: 'FR5045', fab: '"FR 5045.0"&upmdepth', lenz: 4.5, folga: 2.6, larg: 13, min: 27,
    furo: C5045, meio: meio.(C5045), gav: G5045, resumo: ['Extração total', 'Montagem lateral, 45 mm', 'Destrave da gaveta'] },
  { suf: 'fulterer_fr5047', mod: 'FR 5047', cod: 'FR5047', fab: '"FR 5047.0"&upmdepth', lenz: 4.7, folga: 2.6, larg: 13, min: 27,
    furo: C5045, meio: meio.(C5045), gav: G5045, resumo: ['Capacidade de carga até 60kg', 'Extração total', 'Montagem lateral, 47 mm', 'Destrave da gaveta'] },
  { suf: 'fulterer_fr5046_ecd', mod: 'FR 5046 ECD', cod: 'FR5046_ECD', fab: '"FR 5046.0"&upmdepth&" ECD"', lenz: 4.55, folga: 2.6, larg: 13, min: 27,
    furo: C5046, meio: meio.(C5046, 25 => 0.7, 30 => 6.7), gav: G5046, resumo: ['Capacidade de carga até 60kg', 'Extração total', 'Amortecedor (fechamento suave)', 'Destrave da gaveta'] },
  { suf: 'fulterer_fr5210_oe_ecd', mod: 'FR 5210 OE ECD', cod: 'FR5210_OE_ECD', fab: '"FR 5210.0"&upmdepth&" OE ECD"', lenz: 5.19, folga: 2.7, larg: 13.4, min: 40,
    furo: C5210, meio: meio.(C5210), gav: G5210, resumo: ['Capacidade de carga até 90kg', 'Sobre-extração (25 mm além)', 'Amortecedor (fechamento suave)', 'Destrave da gaveta'] }
]

feitos = []
FUL.each_with_index do |f, i|
  g = copia.(SRC_TEL, 700 * (i + 1), f[:suf])
  k = busca.(g, /\Acorredica_hafele_telescopica_normal/) or raise 'kit telescopico nao achado'
  renomeia.(k, f[:suf])
  k.definition.name = model.definitions.unique_name("corredica_#{f[:suf]}")
  seta.(k, 'description', "Corrediça Telescópica Fulterer #{f[:mod]}")
  formula.(k, 'itemcode', "\"CM_KIT_COR_FULTERER_#{f[:cod]}_\"&upmdepth")
  seta.(k, 'codfabricante', ''); formula.(k, 'codfabricante', f[:fab])
  k.definition.set_attribute(DA, '_codfabricante_label', 'codfabricante')
  formula.(k, 'lenz', f[:lenz].to_s)
  seta.(k, 'diffbodyrail', f[:folga].to_s)
  formula.(k, 'upmwidth', f[:larg].to_s)
  seta.(k, 'summary', '')
  # alerta fora da tabela de furos (keyalert vem antes de summary no alfabeto; parent!leny = comprimento)
  seta.(k, 'minlength', f[:min].to_s); seta.(k, 'maxlength', '60')
  formula.(k, 'keyalert', 'if(or(parent!leny>maxlength,parent!leny<minlength),0,1)')
  formula.(k, 'summary', "\"<font color=blue size=2><ul class=pl-10>#{f[:resumo].map { |r| "<li>#{r}</li>" }.join}</ul></font>\"&" \
    "if(keyalert=0,\"<font color=red>Comprimento fora da tabela (#{f[:min] * 10} a 600 mm)</font>\",\"<br>\")")
  logo_mod = texto.("texto_#{f[:suf]}", f[:mod], 4, CINZA)
  filhos.(k).each do |lado|                      # CorrediçaEsq / CorrediçaDir
    filhos.(lado).each do |p|
      if p.definition.name =~ /\ABase/
        formula.(p, 'y', '0.3')                   # 2 mm atras da frente do movel
        fs = furos.(p)
        fr = fs.find { |h| h.get_attribute(DA, '_y_formula') == '3.5' }
        me = fs.find { |h| h.get_attribute(DA, '_y_formula') == '16.3' }
        tr = (fs - [fr, me]).first
        fr.set_attribute(DA, '_y_formula', '3.5')                       # 35 do perfil = 37 da frente do movel
        me.set_attribute(DA, '_y_formula', tab.(f[:meio]))              # 99 ou 259
        tr.set_attribute(DA, '_y_formula', tab.(f[:furo]))              # ultimo 6,2 do perfil
      elsif p.definition.name =~ /\ATrilho/
        formula.(p, 'y', 'if(parent!open=0,0.2,-(leny)+0.2)')
        fs = furos.(p).sort_by { |h| h.get_attribute(DA, '_y_formula') == '3.5' ? 0 : (h.get_attribute(DA, '_y_formula') == '16.3' ? 1 : 2) }
        3.times { |j| fs[j].set_attribute(DA, '_y_formula', tab.(f[:gav].transform_values { |v| v[j] })) }
        ti = filhos.(p).find { |c| c.definition.name =~ /\Atrilho_interno/ }
        filhos.(ti).each do |c|
          if c.definition.name =~ /\Alogo_hafele/ then troca_texto.(c, LOGO_FUL)
          elsif c.definition.name =~ /\ANormal/ then troca_texto.(c, logo_mod)
          end
        end
      end
    end
  end
  feitos << [g, k]
end

# ---------------- Ocultas: UniHide (FGVTN) e Fulterer 40 kg / 60 kg (copias da UniHide) ----------------
E = { 30 => 22.4, 35 => 22.4, 40 => 22.4, 45 => 25.6, 50 => 28.8, 55 => 28.8 }   # cota E do manual (mm/10)
# ultimo furo do movel (cm da frente do movel, ja com a folga frontal de 2 mm): tabelas do usuario (Fulterer)
O40 = { 27 => 16.5, 30 => 22.9, 35 => 26.1, 40 => 26.1, 45 => 29.3, 50 => 32.5, 55 => 32.5, 60 => 38.9 }
O60 = { 45 => 29.3, 50 => 29.3, 60 => 29.3 }
# furo do pino traseiro (manual UniHide): 7 mm da face interna da lateral, 38 mm acima da base da corredica (11 acima
# do apoio da gaveta no carro): a altura do molde (z 3.8) ja esta certa. Broca: o manual pede o7 (molde: f_5mm).
OCU = [
  { suf: 'fgvtn_unihide_slowmotion', ren: 'fgvtn_unihide', kit: 'kit_corredica_fgvtn_unihide_slowmotion', dx: 700,
    desc: 'Corrediça Oculta UniHide Slowmotion', item: '"CM_KIT_COR_OCU_FGVTN_UNIHIDE_"&LenY*10',
    fab: 'concatenate("54OC1812",round(LenY*10),"TSX0")', min: 30, max: 55, ultimo: E.transform_values { |v| (v + 3.7).round(2) },
    resumo: ['Capacidade de carga até 40kg', 'Extração total', 'Slowmotion (fechamento suave)', 'Laterais de 15 e 18 mm'],
    texto: ['texto_fgvtn_unihide', 'UniHide', 5, VERDE], logo: true },
  { suf: 'fulterer_oculta_40kg', ren: 'fulterer_oculta_40kg', kit: 'kit_corredica_fulterer_oculta_40kg', dx: 1400,
    desc: 'Corrediça Oculta Fulterer 40kg', item: '"CM_KIT_COR_OCU_FULTERER_40KG_"&LenY*10', fab: nil, min: 27, max: 60, ultimo: O40,
    resumo: ['Capacidade de carga até 40kg', 'Extração total', 'Amortecedor (fechamento suave)', 'Laterais de 15 e 18 mm'],
    texto: ['texto_fulterer_oculta', 'Fulterer', 5, VERMELHO], logo: false },
  { suf: 'fulterer_oculta_60kg', ren: 'fulterer_oculta_60kg', kit: 'kit_corredica_fulterer_oculta_60kg', dx: 2100,
    desc: 'Corrediça Oculta Fulterer 60kg', item: '"CM_KIT_COR_OCU_FULTERER_60KG_"&LenY*10', fab: nil, min: 45, max: 60, ultimo: O60,
    resumo: ['Capacidade de carga até 60kg', 'Extração total', 'Amortecedor (fechamento suave)', 'Laterais de 15 e 18 mm'],
    texto: ['texto_fulterer_oculta', 'Fulterer', 5, VERMELHO], logo: false }
]
OCU.each do |o|
  g = copia.(SRC_OCU, o[:dx], o[:suf])
  k = busca.(g, /\Akit_corredica_hd_invisivel/) or raise 'kit oculto nao achado'
  renomeia.(k, o[:ren])
  k.definition.name = model.definitions.unique_name(o[:kit])
  seta.(k, 'description', o[:desc])
  formula.(k, 'itemcode', o[:item])   # provisorio
  seta.(k, 'codfabricante', '')
  if o[:fab]
    formula.(k, 'codfabricante', o[:fab])
    k.definition.set_attribute(DA, '_codfabricante_label', 'codfabricante')
  end
  seta.(k, 'minlength', o[:min].to_s); seta.(k, 'maxlength', o[:max].to_s)
  # manual UniHide: vao INTERNO da gaveta = N - 49 (24,5 da lateral do movel ate a face INTERNA da lateral da gaveta).
  # Folga por fora = 24,5 - espessura da lateral (15,5 -> 9 mm por lado). O molde HD tinha 1.1 fixo.
  seta.(k, 'diffbodyrail', '1.8'); formula.(k, 'diffbodyrail', '2*(2.45-parent!thickness)')
  # a base_gaveta do molde HD lia "kit_corredica!diffbody" (cortado): nunca pegava a folga do kit
  formula.(busca.(g, /\Abase_gaveta/), 'diffbodyrail', 'kit_corredica!diffbodyrail')
  seta.(k, 'summary', '')
  formula.(k, 'summary', "\"<font color=blue size=2><ul class=pl-10>#{o[:resumo].map { |r| "<li>#{r}</li>" }.join}</ul></font>\"&" \
    "if(or(leny>maxlength,leny<minlength),\"<font color=red>Comprimento fora da tabela (#{o[:min] * 10} a #{o[:max] * 10} mm)</font>\",\"<br>\")")
  # no carro: o texto "HD" sai e o "Soft Closing" vira o texto da marca; o logo FGVTN (grupo) fica so na UniHide
  txt = texto.(*o[:texto])
  filhos.(k).each do |lado|
    # furos do movel ja existem no lado (molde HD: 37/165/261); viram 37, 69 e o ultimo da tabela.
    # y local = distancia da frente do movel + 1 mm (o kit fica 1 mm a frente do movel).
    fs = furos.(lado)
    f2 = fs.find { |h| h.get_attribute(DA, '_y_formula') == '16.1+0.5' }
    f3 = fs.find { |h| h.get_attribute(DA, '_y_formula').to_s.start_with?('if(parent!leny<=35') }
    raise 'furos do molde oculto nao achados' unless f2 && f3
    f2.set_attribute(DA, '_y_formula', '6.9+0.1')
    f3.set_attribute(DA, '_y_formula', "#{tab.(o[:ultimo])}+0.1")
    # perfil da gaveta a partir da face interna da lateral (24,5 do movel): carro +1 mm, pino e furo traseiro +7 (manual),
    # rebaixo +3. O molde tinha carro a 22 mm: entrava 2,5 mm no MDF da lateral. Direita = mesmo valor negativo.
    sx = lado.definition.name =~ /esquerda/ ? '' : '-'
    posx = { /\Acarro_corredica/ => '2.45+0.1', /\Apino_guia/ => '2.45+0.7', /\Arebaixo_gaveta/ => '2.45+0.3' }
    filhos.(lado).each { |p| posx.each { |re, v| formula.(p, 'x', "#{sx}(#{v})") if p.definition.name =~ re } }
    fs.select { |h| h.get_attribute(DA, '_y_formula').to_s =~ /open/ }.each do |h|
      h.set_attribute(DA, '_x_formula', "#{sx}(2.45+0.7)")
      h.set_attribute(DA, 'upmtool', 'f_7mm')
      h.set_attribute(DA, 'upmdiameter', '7')
    end
    filhos.(lado).each do |p|
      # base do molde tinha 280 mm fixos: o ultimo furo (293/325) caia fora do metal. Segue o comprimento (5 mm de cada ponta).
      formula.(p, 'leny', 'parent!leny-1') if p.definition.name =~ /\ABaseCorredicaOculta/
      next unless p.definition.name =~ /\Acarro_corredica/
      filhos.(p).each do |c|
        if c.definition.name =~ /\AHD/ then c.erase!
        elsif c.definition.name =~ /\ASoft Closing/ then troca_texto_plano.(c, txt, p)
        end
      end
      p.definition.entities.grep(Sketchup::Group).each(&:erase!) unless o[:logo]   # logo FGVTN
    end
  end
  feitos << [g, k]
end

feitos.each { |gg, _| dcc.redraw_with_undo(gg) }
feitos.each { |gg, kk| puts "#{gg.definition.name} > #{kk.definition.name}: #{kk.get_attribute(DA, 'description')} | #{kk.get_attribute(DA, 'itemcode')} | #{kk.get_attribute(DA, 'codfabricante')}" }

# encoding: UTF-8
# Importa moldes do catalogo do plugin (biblioteca antiga), lista a arvore (3 niveis) com _name, itemcode, type,
# formulas de medida e campos editaveis, grava em SAIDA e DESFAZ tudo no fim (raise). Uso: ajuste ARQUIVOS.
PASTA = File.join(ENV['APPDATA'].tr("\\", '/'), 'SketchUp', 'SketchUp 2026', 'SketchUp', 'Plugins', 'componentes_upmobb', 'banco', 'componentes', 'upmobb')
ARQUIVOS = %w[caixa_balcao balcao_com_tampo conjunto_gavetas_2und prateleira_1und porta_de_giro_sem_puxdor
              kit_corredica_invisivel_generica corredica_tn_telescopica_normal divisoria_1und frente_gaveta]
SAIDA = File.join(ENV['TEMP'], 'estudo_catalogo.txt')
NIVEIS = 3
DA = 'dynamic_attributes'
m = ->(v) { (v.to_f * 25.4).round(1) }
chaves = /\A(_name|itemcode|_itemcode_formula|type|name|description|modeloptions|materialoptions|componentedit|parentrefresh|atttransfer|_len[xyz]_formula|_inst__[xyz]_formula|_[xyz]_formula|_onclick|onclick|keyalert|_keyalert_formula|diffbodyrail|reduceforbody|lengthrails|_lengthrails_formula|extract|open|_open_formula)\z/
out = []
anda = lambda do |e, n|
  d = e.definition
  a = ->(k) { e.get_attribute(DA, k) || d.get_attribute(DA, k) }
  b = d.bounds
  out << "#{'  ' * n}#{e.is_a?(Sketchup::Group) ? 'G' : 'C'} #{d.name} [#{a.('_name')}] #{[b.width, b.height, b.depth].map(&m).join('x')}"
  [d, e].uniq.each do |o|
    dd = o.attribute_dictionary(DA) or next
    dd.keys.sort.each { |k| out << "#{'  ' * n}  #{o == d ? 'D' : 'I'} #{k}=#{dd[k].to_s[0, 200]}" if k =~ chaves && !dd[k].to_s.empty? }
    dd.keys.select { |k| k =~ /_formlabel\z/ }.each { |k| c = k.sub(/\A_/, '').sub(/_formlabel\z/, ''); out << "#{'  ' * n}  F #{c}: #{dd[k].to_s.gsub(/<[^>]+>/, '')[0, 60]} (#{dd["_#{c}_access"]}) #{dd["_#{c}_options"].to_s[0, 120]}" } if o == d
  end
  return if n >= NIVEIS
  d.entities.each { |c| anda.(c, n + 1) if c.respond_to?(:definition) && c.definition.name !~ /\A(Chapa de MDF|upmedge|.*selector)/ }
end
x = 0
ARQUIVOS.each do |nome|
  arq = Dir[File.join(PASTA, "*__#{nome}.skp")].max_by { |f| File.mtime(f) }
  unless arq then out << "== #{nome}: nao achado"; next; end
  d = model.definitions.load(arq)
  i = model.entities.add_instance(d, Geom::Transformation.translation([x, -5000.mm, 0])); x += 1500.mm
  out.push "", "==================== #{nome} (#{File.basename(arq)})"
  anda.(i, 0)
end
File.write(SAIDA, out.join("\n"))
raise "#{SAIDA}: #{out.size} linhas (desfeito)"

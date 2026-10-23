# Despeja um produto inteiro (arvore + atributos/formulas de definicao e instancia, sem ruido) num arquivo texto.
# Uso: ALVO = nome da definicao no nivel de cima; SAIDA = arquivo; PULA = o que nao abrir (MDF/fitas/ferragens repetidas).
ALVO = 'conteiner'
SAIDA = File.join(ENV['TEMP'], "dump_#{ALVO}.txt")
PULA = /\A(Chapa de MDF|upmedge|.*_selector|mini_fix|cavilha|parafuso|CabecaParafuso)/
NIVEIS = 8
DA = 'dynamic_attributes'
ruido = /summary_error|_error\z|_label\z|iscollapsed|_lastmodified|_formatversion|behaviors|upmdraw|_nominal\z|_access\z\z_NAO/
m = ->(v) { (v.to_f * 25.4).round(1) }
out = []
lista = lambda do |o|
  d = o.attribute_dictionary(DA) or return []
  d.keys.sort.reject { |k| k =~ ruido || d[k].to_s.empty? }.map { |k| "#{k}=#{d[k].to_s[0, 220]}" }
end
vistos = {}
anda = lambda do |e, t, n|
  d = e.definition
  tt = t * e.transformation
  b = Geom::BoundingBox.new; 8.times { |i| b.add(d.bounds.corner(i).transform(tt)) }
  nm = e.get_attribute(DA, '_name') || d.get_attribute(DA, '_name')
  pre = '  ' * n
  out << "#{pre}#{e.is_a?(Sketchup::Group) ? 'G' : 'C'} #{d.name} [#{nm}] #{[b.width, b.height, b.depth].map(&m).join('x')} @#{b.min.to_a.map(&m).join(',')}#{e.hidden? ? ' OCULTO' : ''}"
  if vistos[d]
    out << "#{pre}  (definicao ja listada)"
  else
    vistos[d] = true
    lista.(d).each { |l| out << "#{pre}  D #{l}" } unless e.is_a?(Sketchup::Group)
    lista.(e).each { |l| out << "#{pre}  I #{l}" }
  end
  return if n >= NIVEIS || d.name =~ PULA
  d.entities.each { |c| anda.(c, tt, n + 1) if (c.is_a?(Sketchup::ComponentInstance) || c.is_a?(Sketchup::Group)) && !(c.definition.name =~ PULA && n > 0) }
end
g = model.entities.grep(Sketchup::ComponentInstance).find { |x| x.definition.name == ALVO } or raise 'nao achei'
anda.(g, IDENTITY, 0)
File.write(SAIDA, out.join("\n"))
puts "#{SAIDA}: #{out.size} linhas"

# Atributos e formulas de um componente (definicao e instancia), sem o ruido.
# Uso: troque PID pelo persistent_id (veja arvore.rb). FILTRO opcional (regex de chave).
PID = 0
FILTRO = nil        # ex.: /formula|rebaixo|edge/
e = model.find_entity_by_persistent_id(PID) or raise "pid #{PID} nao encontrado"
ruido = /summary|_error\z|_label\z|_options\z|iscollapsed|_lastmodified|_formatversion|behaviors|upmdraw|upmtext|_nominal\z/
lista = lambda do |o|
  d = o.attribute_dictionary('dynamic_attributes') or return []
  d.keys.reject { |k| k =~ ruido }.select { |k| FILTRO.nil? || k =~ FILTRO }.map { |k| "#{k}=#{d[k].to_s[0, 140]}" }
end
puts "== DEFINICAO #{e.definition.name}", lista.call(e.definition), '== INSTANCIA', lista.call(e)
mm = ->(v) { (v.to_f * 25.4).round(1) }
filhos = e.definition.entities.select { |c| c.respond_to?(:definition) }
puts '== FILHOS (bounds no pai, mm)'
filhos.each do |c|
  b = Geom::BoundingBox.new; 8.times { |i| b.add(c.definition.bounds.corner(i).transform(c.transformation)) }
  nm = c.get_attribute('dynamic_attributes', '_name') || c.definition.get_attribute('dynamic_attributes', '_name')
  puts "#{c.definition.name} [#{nm}] #{[b.width, b.height, b.depth].map(&mm)} min #{b.min.to_a.map(&mm)} pid=#{c.persistent_id}"
end

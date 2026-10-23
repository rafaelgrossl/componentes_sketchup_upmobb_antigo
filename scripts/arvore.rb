# Arvore de um componente da cena, com medidas em mm (mundo) e type.
# Uso: troque ALVO pelo nome da definicao do produto (ou nil = todos do nivel de cima) e envie pela ponte.
ALVO = nil          # ex.: 'balcao#2'
NIVEIS = 3          # profundidade
PULA = /Borda|Chapa de MDF|upmedge|selector|Agrupar|kit_|Grupo/   # o que nao abrir/listar
mm = ->(v) { (v.to_f * 25.4).round(1) }
l = []
anda = lambda do |ents, tr, nivel|
  ents.each do |e|
    next unless e.is_a?(Sketchup::ComponentInstance) || e.is_a?(Sketchup::Group)
    d = e.definition
    next if nivel > 0 && d.name =~ PULA
    t = tr * e.transformation
    b = Geom::BoundingBox.new; 8.times { |i| b.add(d.bounds.corner(i).transform(t)) }
    nm = e.get_attribute('dynamic_attributes', '_name') || d.get_attribute('dynamic_attributes', '_name')
    l << "#{'  ' * nivel}#{e.is_a?(Sketchup::Group) ? 'G' : 'C'} #{d.name} [#{nm}] #{[b.width, b.height, b.depth].map(&mm).join('x')} " \
         "@#{b.min.to_a.map(&mm).join(',')} pid=#{e.persistent_id} t=#{d.get_attribute('dynamic_attributes', 'type')}"
    anda.call(d.entities, t, nivel + 1) if nivel < NIVEIS
  end
end
raiz = model.entities.select { |e| e.respond_to?(:definition) && (ALVO.nil? || e.definition.name == ALVO) }
anda.call(raiz, IDENTITY, 0)
puts l.join("\n")

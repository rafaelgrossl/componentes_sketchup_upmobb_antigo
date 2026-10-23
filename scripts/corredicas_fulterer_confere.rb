# Confere as gavetas das corredicas Fulterer / UniHide: furos (distancia da frente do movel, x, z) e textos.
# NOMES: definicoes das gavetas de teste. Opcional: LEN = comprimento a testar (cm) ou nil.
NOMES = %w[conteiner_gaveta_fulterer_fr5045 conteiner_gaveta_fulterer_fr5047 conteiner_gaveta_fulterer_fr5046_ecd
           conteiner_gaveta_fulterer_fr5210_oe_ecd conteiner_gaveta_fgvtn_unihide_slowmotion
           conteiner_gaveta_fulterer_oculta_40kg conteiner_gaveta_fulterer_oculta_60kg]
DA = 'dynamic_attributes'
m = ->(v) { (v.to_f * 25.4).round(1) }
NOMES.each do |nm|
  g = model.entities.grep(Sketchup::ComponentInstance).find { |e| e.definition.name == nm } or next
  frente = nil; l = []; txt = []
  anda = lambda do |ents, tr|
    ents.each do |e|
      next unless e.respond_to?(:definition)
      t = tr * e.transformation
      if e.definition.name =~ /\Aedge_conteiner/
        b = Geom::BoundingBox.new; 8.times { |i| b.add(e.definition.bounds.corner(i).transform(t)) }; frente ||= b.min.y
      elsif e.is_a?(Sketchup::Group) && e.name =~ /Hole/
        next if e.hidden?
        p = ORIGIN.transform(t); q = e.entities.grep(Sketchup::Edge).first
        dir = q ? (q.end.position.transform(t) - q.start.position.transform(t)).normalize.to_a.map { |v| v.round(1) } : nil
        l << [e.parent.name.sub(/_(fulterer|fgvtn).*/, ''), p, dir]
      else
        txt << "#{e.definition.name} #{m.(e.bounds.width)}x#{m.(e.bounds.height)}x#{m.(e.bounds.depth)}" if e.definition.name =~ /\A(logo|texto)_/
        anda.(e.definition.entities, t) unless e.definition.name =~ /Chapa de MDF|edge|Borda/
      end
    end
  end
  anda.(g.definition.entities, g.transformation)
  k = nil; fk = ->(i) { i.definition.entities.grep(Sketchup::ComponentInstance).each { |c| k ||= c if c.get_attribute(DA, '_name') == 'kit_corredica' || c.definition.get_attribute(DA, '_name') == 'kit_corredica'; fk.(c) unless k } }; fk.(g)
  puts "== #{nm}: len=#{m.(k.get_attribute(DA, 'leny'))} cod=#{k.get_attribute(DA, 'itemcode')} fab=#{k.get_attribute(DA, 'codfabricante')}"
  l.sort_by { |a| [a[0], a[1].x.round(2), a[1].y] }.each { |n, p, d| puts "  #{n}: y=#{m.(p.y - frente)} x=#{m.(p.x - g.transformation.origin.x)} z=#{m.(p.z)} dir=#{d}" }
  puts "  textos: #{txt.tally}"
end

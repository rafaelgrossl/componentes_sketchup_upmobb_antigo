# Compara duas gavetas/produtos peça a peça: medidas (mm, pelos cantos da definição) e posição relativa à origem.
# Uso: ajuste NOMES (definições do nível de cima: molde e cópia) e envie pela ponte.
while model.active_path; model.close_active; end
DA='dynamic_attributes'
m=->(v){(v.to_f*25.4).round(1)}
NOMES = %w(conteiner conteiner_gaveta_fgvtn_unihide_slowmotion)
NOMES.each do |nm|
  g = model.entities.grep(Sketchup::ComponentInstance).find{|e| e.definition.name==nm}
  o = g.transformation.origin
  anda = lambda do |ents,t,n|
    ents.each do |e|
      next unless e.respond_to?(:definition)
      next if e.definition.name =~ /Chapa de MDF|Borda|edge|mini_fix|cavilha|parafuso|Transfer|kit_minifix/
      tt=t*e.transformation; b=Geom::BoundingBox.new; 8.times{|i| b.add(e.definition.bounds.corner(i).transform(tt))}
      puts "#{'  '*n}#{e.definition.name.sub(/_fgvtn_unihide.*|#\d+/,'')} #{[b.width,b.height,b.depth].map(&m).join('x')} @#{[b.min.x-o.x,b.min.y-o.y,b.min.z-o.z].map(&m).join(',')} hid=#{e.hidden?}"
      anda.(e.definition.entities,tt,n+1) if n<5 && e.definition.name !~ /corpo_gaveta|chapa_frente|contra/
    end
  end
  puts "== #{nm}"; anda.(g.definition.entities,g.transformation,0)
end

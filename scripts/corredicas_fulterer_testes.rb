# Testa as corredicas Fulterer / UniHide em varios comprimentos (desfeito no fim com raise).
# Mostra os furos do movel (base/lado) e da gaveta (trilho) em mm da frente do movel (kit fica 1 mm a frente).
DA = 'dynamic_attributes'
dcc = $dc_observers.get_latest_class
LENS = [25, 27, 30, 35, 40, 45, 50, 55, 60, 65, 70]
m = ->(v) { (v.to_f * 25.4).round(1) }
kits = []
model.entities.grep(Sketchup::ComponentInstance).each do |g|
  next unless g.definition.name =~ /\Aconteiner_gaveta_(fulterer|fgvtn_unihide)/
  fk = ->(i) { i.definition.entities.grep(Sketchup::ComponentInstance).each { |c| (c.definition.name =~ /\A(corredica_fulterer|kit_corredica_fgvtn|kit_corredica_fulterer)/) ? kits << [g, c] : fk.(c) } }
  fk.(g)
end
out = []
kits.each do |g, k|
  out << "== #{k.definition.name}"
  LENS.each do |l|
    [k.definition, k].each { |o| o.set_attribute(DA, '_leny_formula', l.to_s) }
    dcc.redraw(k, false)
    tk = nil; acha = ->(i, t) { i.definition.entities.grep(Sketchup::ComponentInstance).each { |c| tt = t * c.transformation; tk = tt if c == k; acha.(c, tt) unless tk } }
    acha.(g, g.transformation)
    frente = ORIGIN.transform(tk).y   # origem do kit = frente? usa o menor y dos furos de referencia abaixo
    pts = Hash.new { |h, kk| h[kk] = [] }
    anda = lambda do |ents, t|
      ents.each do |e|
        next unless e.respond_to?(:definition)
        tt = t * e.transformation
        if e.is_a?(Sketchup::Group) && e.name =~ /Hole/
          next if e.hidden? || e.get_attribute(DA, '_y_formula').to_s =~ /open/
          lado = e.parent.name =~ /Trilho/ ? 'gav' : 'mov'
          pts[lado] << ORIGIN.transform(tt).y if e.parent.name =~ /Esq|esquerda/
        else
          anda.(e.definition.entities, tt)
        end
      end
    end
    anda.(k.definition.entities, tk)
    b = Geom::BoundingBox.new; k.definition.entities.grep(Sketchup::ComponentInstance).each { |c| 8.times { |i| b.add(c.definition.bounds.corner(i).transform(tk * c.transformation)) } }
    f0 = b.min.y + 1.0 / 25.4
    out << "  #{l * 10}: movel #{pts['mov'].map { |y| m.(y - f0) }.sort} gaveta #{pts['gav'].map { |y| m.(y - f0) }.sort} | #{k.get_attribute(DA, 'itemcode')} #{k.get_attribute(DA, 'codfabricante')}"
  end
end
raise out.join("\n")

# Foto (fundo branco, sem arestas) da corredica esquerda de cada gaveta de teste, aberta, vista do lado do movel
# (o logo fica no perfil que sai). Tudo desfeito no fim (raise); a camera volta. Saida: PASTA/<kit>.png 800x800.
# Outros alvos: defina antes $foto_alvos / $foto_kit / $foto_vista. Ex. ocultas Fulterer: /\Aconteiner_gaveta_fulterer_oculta/,
# /\Akit_corredica_fulterer_oculta/, vista [1.0, -1.1, 0.55] (texto no lado de dentro do carro).
ALVOS = $foto_alvos || /\Aconteiner_gaveta_fulterer_fr/
KIT = $foto_kit || /\Acorredica_fulterer/
PASTA = File.join(ENV['TEMP'], 'fotos_componentes')
VISTA = $foto_vista || [-1.0, -1.1, 0.55]
DA = 'dynamic_attributes'
dcc = $dc_observers.get_latest_class
Dir.mkdir(PASTA) unless Dir.exist?(PASTA)
v = model.active_view; c0 = v.camera; cam0 = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
ro = model.rendering_options
ro['DrawGround'] = false; ro['DrawHorizon'] = false; ro['BackgroundColor'] = Sketchup::Color.new(255, 255, 255)
ro['EdgeDisplayMode'] = 0; ro['DrawSilhouettes'] = false; ro['ModelTransparency'] = false
caminho = lambda do |ents, t, re, path|
  ents.each { |e| next unless e.respond_to?(:definition); tt = t * e.transformation; return [path + [e], tt] if e.definition.name =~ re; r = caminho.(e.definition.entities, tt, re, path + [e]); return r if r }
  nil
end
model.definitions.each { |d| d.entities.grep(Sketchup::Group).each { |g| g.hidden = true if g.name =~ /Hole/ } }
saidas = []
model.entities.grep(Sketchup::ComponentInstance).select { |g| g.definition.name =~ ALVOS }.each do |g|
  path, t = caminho.(g.definition.entities, g.transformation, KIT, [g])
  k = path.last
  [k.definition, k].each { |o| o.set_attribute(DA, '_open_formula', '1') }
  dcc.redraw(k, false)
  path, t = caminho.(g.definition.entities, g.transformation, KIT, [g])
  model.entities.each { |e| e.hidden = (e != g) if e.respond_to?(:hidden=) }
  path.each_cons(2) { |pai, filho| pai.definition.entities.each { |e| e.hidden = (e != filho) if e.respond_to?(:hidden=) && (e.respond_to?(:definition) || e.is_a?(Sketchup::Face)) } }
  esq = k.definition.entities.grep(Sketchup::ComponentInstance).find { |c| c.definition.name =~ /Esq|esquerda/ }
  k.definition.entities.each { |e| e.hidden = (e != esq) if e.respond_to?(:hidden=) && e.respond_to?(:definition) }
  b = Geom::BoundingBox.new
  esq.definition.entities.grep(Sketchup::ComponentInstance).each { |c| 8.times { |i| b.add(c.definition.bounds.corner(i).transform(t * esq.transformation * c.transformation)) } }
  dir = Geom::Vector3d.new(*VISTA); dir.length = b.diagonal * 2
  v.camera = Sketchup::Camera.new(b.center.offset(dir), b.center, [0, 0, 1], true, 30)
  v.zoom(b) rescue nil
  f = File.join(PASTA, "#{k.definition.name}.png"); v.write_image(filename: f, width: 800, height: 800, antialias: true); saidas << f
end
v.camera = cam0
raise saidas.join(' ')

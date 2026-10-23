# Foto de produto (fundo branco, sem arestas nem chao) de cada componente para a minifoto.
# Uso: ajuste ALVOS (regex do nome do grupo/definicao no nivel de cima), VISTA e PASTA; envie pela ponte.
# Restaura camera e estilo no fim. Saida: <PASTA>/<nome>.png (800x800).
ALVOS = /\Afix_rodizio_rg/
PASTA = File.join(ENV['TEMP'], 'fotos_componentes')
# vista por nome: [direcao do olho em relacao ao centro, vetor "para cima" da camera]
# rodizio: base em z=0 e roda para +z -> camera de cabeca para baixo (roda embaixo na foto)
VISTAS = { /rodizio/ => [[1.0, -1.6, -0.9], [0, 0, -1]] }
VISTA = [1.0, -1.6, 0.9]       # padrao (de cima, de frente/lado)
CIMA  = [0, 0, 1]
ARESTAS = false                # true: mostra arestas (peca branca sobre fundo branco)
while model.active_path; model.close_active; end
Dir.mkdir(PASTA) unless Dir.exist?(PASTA)
v = model.active_view
c0 = v.camera; cam0 = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
ro = model.rendering_options
guarda = %w(DrawGround DrawHorizon BackgroundColor EdgeDisplayMode DrawSilhouettes ModelTransparency DisplaySketchAxes).to_h { |k| [k, ro[k]] }
vis = model.entities.select { |e| e.respond_to?(:hidden?) && !e.hidden? }
alvos = model.entities.select { |e| (e.is_a?(Sketchup::Group) ? e.name : (e.respond_to?(:definition) ? e.definition.name : '')) =~ ALVOS }
saidas = []
# furos e guias (grupos 'Hole', camada UpGuias) somem na foto
guias = model.definitions.flat_map { |d| d.entities.grep(Sketchup::Group).select { |g| g.name =~ /Hole/ && !g.hidden? } }
begin
  ro['DrawGround'] = false; ro['DrawHorizon'] = false; ro['BackgroundColor'] = Sketchup::Color.new(255, 255, 255)
  ro['EdgeDisplayMode'] = ARESTAS ? 1 : 0; ro['DrawSilhouettes'] = false; ro['ModelTransparency'] = false   # true = raio-X
  guias.each { |g| g.hidden = true }
  alvos.each do |a|
    model.entities.each { |e| e.hidden = (e != a) if e.respond_to?(:hidden=) }
    nome = a.is_a?(Sketchup::Group) ? a.name : a.definition.name.sub(/#\d+\z/, '')
    b = a.bounds; c = b.center
    d = b.diagonal * 2.2
    vista, cima = VISTAS.find { |re, _| nome =~ re }&.last || [VISTA, CIMA]
    dir = Geom::Vector3d.new(*vista); dir.length = d
    v.camera = Sketchup::Camera.new(c.offset(dir), c, Geom::Vector3d.new(*cima), true, 30)
    v.zoom(a)
    # a tela e mais larga que a foto quadrada: abre o angulo para nao cortar as laterais
    asp = v.vpwidth.to_f / v.vpheight
    v.camera.fov = [v.camera.fov * asp * 1.05, 100].min if asp > 1
    v.refresh
    f = File.join(PASTA, "#{nome}.png")
    v.write_image(filename: f, width: 800, height: 800, antialias: true)
    saidas << f
  end
ensure
  guarda.each { |k, val| ro[k] = val }
  guias.each { |g| g.hidden = false }
  model.entities.each { |e| e.hidden = !vis.include?(e) if e.respond_to?(:hidden=) }
  v.camera = cam0
end
puts saidas

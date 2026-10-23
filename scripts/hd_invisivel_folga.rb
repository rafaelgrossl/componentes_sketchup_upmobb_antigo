# Gaveta original da HD Invisivel (cena corredicas_sabin): mesma folga e posicao do perfil da gaveta da UniHide
# (manual: 24,5 da lateral do movel ate a face interna da lateral da gaveta). Ver componentes/corredicas_fulterer_unihide.md.
ALVO = 'conteiner'
while model.active_path; model.close_active; end
DA = 'dynamic_attributes'
g = model.entities.grep(Sketchup::ComponentInstance).find { |x| x.definition.name == ALVO } or raise 'gaveta nao achada'
k = nil
b = ->(i) { i.definition.entities.grep(Sketchup::ComponentInstance).each { |c| c.definition.name =~ /\Akit_corredica_hd_invisivel/ ? k = c : (b.(c) unless c.definition.name =~ /corpo|chapa/) } }
b.(g)
pf = ->(c, kk, v) { c.definition.set_attribute(DA, "_inst__#{kk}_formula", v); c.set_attribute(DA, "_#{kk}_formula", v) }
k.definition.entities.grep(Sketchup::ComponentInstance).each do |lado|
  sx = lado.definition.name =~ /esquerda/ ? '' : '-'
  { /\Acarro_corredica/ => '2.45+0.1', /\Apino_guia/ => '2.45+0.7', /\Arebaixo_gaveta/ => '2.45+0.3' }.each do |re, v|
    lado.definition.entities.grep(Sketchup::ComponentInstance).each { |p| pf.(p, 'x', "#{sx}(#{v})") if p.definition.name =~ re }
  end
  lado.definition.entities.grep(Sketchup::Group).each { |h| h.set_attribute(DA, '_x_formula', "#{sx}(2.45+0.7)") if h.name =~ /Hole/ && h.get_attribute(DA, '_y_formula').to_s =~ /open/ }
end
d = $dc_observers.get_latest_class
d.redraw_with_undo(g)

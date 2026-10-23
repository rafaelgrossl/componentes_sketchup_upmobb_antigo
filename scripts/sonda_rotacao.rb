# Descobre a rotacao de uma peca testando candidatos e medindo (no fim desfaz tudo com raise).
# Uso: PID da peca, PRODUTO (definicao do produto para redesenhar), CANDIDATOS [rotx, roty, rotz].
PID = 0
PRODUTO = 'balcao#2'
CANDIDATOS = [[-90, 90, 0], [-90, -90, 0], [0, -90, 0], [0, 90, 0], [-90, 0, 90], [0, 0, 90], [0, 0, -90], [180, 0, 90]]
DA = 'dynamic_attributes'
c = model.find_entity_by_persistent_id(PID) or raise "pid #{PID} nao encontrado"
top = model.entities.grep(Sketchup::ComponentInstance).find { |i| i.definition.name == PRODUTO }
dcc = $dc_observers.get_latest_class
mm = ->(v) { (v.to_f * 25.4).round(1) }
pf = ->(k, v) { c.definition.set_attribute(DA, "_inst__#{k}_formula", v); c.set_attribute(DA, "_#{k}_formula", v) }
%w[x y z].each { |k| pf.call(k, '0') }
r = CANDIDATOS.map do |rx, ry, rz|
  pf.call('rotx', rx.to_s); pf.call('roty', ry.to_s); pf.call('rotz', rz.to_s)
  dcc.redraw(top, false)
  b = c.bounds
  "#{[rx, ry, rz]} tam=#{[b.width, b.height, b.depth].map(&mm)} min=#{b.min.to_a.map(&mm)} max=#{b.max.to_a.map(&mm)}"
end
raise "sonda (desfeita):\n" + r.join("\n")

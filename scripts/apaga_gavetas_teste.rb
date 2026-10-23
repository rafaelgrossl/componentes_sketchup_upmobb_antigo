# Apaga gavetas de teste do nivel de cima pelo nome da definicao (regex ALVO) e remove so as definicoes
# que ficaram sem uso por causa disso (as que ja estavam sem uso antes continuam).
ALVO = /\Aconteiner_gaveta_(fulterer|fgvtn_unihide)/
antes = model.definitions.select { |d| d.instances.empty? && !d.image? }.map(&:name)
model.entities.grep(Sketchup::ComponentInstance).select { |e| e.definition.name =~ ALVO }.each(&:erase!)
tirou = 0
loop do
  novos = model.definitions.select { |d| d.instances.empty? && !d.image? && !d.group? && !antes.include?(d.name) }
  break if novos.empty?
  novos.each { |d| model.definitions.remove(d); tirou += 1 }
end
puts "definicoes removidas: #{tirou}"

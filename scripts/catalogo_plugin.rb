# encoding: UTF-8
# Gera referencia/catalogo_plugin.md a partir do indice do catalogo do plugin (roda FORA do SketchUp):
#   ruby scripts/catalogo_plugin.rb
# O plugin salva sozinho uma copia de todo componente com upmobb_attributes que aparece num projeto aberto.
require 'json'
INDICE = File.join(ENV['APPDATA'], 'SketchUp', 'SketchUp 2026', 'SketchUp', 'Plugins', 'componentes_upmobb',
                   'banco', 'componentes', 'upmobb', 'indice.json')
GROSSL = /\A(fix_|pec|com_pec|gavetas?_\d_unidade|composta_)/
SESSAO = /fulterer|unihide|ro82|_ro82seq|rodizio_rg/
j = JSON.parse(File.read(INDICE, encoding: 'UTF-8'))
lin = { 'antiga' => [], 'sessao' => [], 'grossl' => [] }
j.values.group_by { |v| v['definicao'].sub(/#\d+\z/, '') }.sort.each do |d, l|
  v = l.max_by { |x| x['dateinsert'].to_s }
  cls = if d =~ SESSAO then 'sessao'
        elsif d =~ GROSSL || v['itemcode'].to_s =~ /\A(PC_|GAV\z|COR_OCU)/ then 'grossl'
        else 'antiga'
        end
  lin[cls] << "| `#{d}` | #{v['nome']} | `#{v['itemcode']}` | #{v['dateinsert'].to_s[0, 10]} | `#{v['arquivo']}` |"
end
cab = "| Definição | Nome | itemcode | dateinsert | Arquivo (banco/componentes/upmobb) |\n|---|---|---|---|---|"
out = <<~TXT
  # Catálogo do plugin (cópias dos componentes da Biblioteca do Upmobb)

  Gerado por `scripts/catalogo_plugin.rb` de `%APPDATA%\\SketchUp\\SketchUp 2026\\SketchUp\\Plugins\\componentes_upmobb\\banco\\componentes\\upmobb\\indice.json`.
  Só leitura. Para usar um molde que não está na cena: importe o `.skp` num comando de teste
  (`d = model.definitions.load(caminho)`; `model.entities.add_instance(d, ...)`).

  Separação pelo nome e pelo código (**confira a estrutura antes de usar**): Grossl = `fix_*`, `pec_*` (`PC_*`), `com_pec*`,
  `composta_*`, `fix_modelo_gaveta` (`GAV`), `fix_corredica` (`COR_OCU_*`). O resto é tratado como biblioteca **antiga**
  (códigos `CM_*`, `kit_*`, `conjunto_*`, `corredica_*`, `conteiner`...). Balcão, portas e puxadores podem existir nas duas.

TXT
out << "## Biblioteca antiga (Upmobb) — #{lin['antiga'].size} definições\n#{cab}\n#{lin['antiga'].join("\n")}\n\n"
out << "## Feitos nas sessões (Fulterer/UniHide = antiga; RO-82 e rodízios RG = Grossl) — #{lin['sessao'].size}\n#{cab}\n#{lin['sessao'].join("\n")}\n\n"
out << "## Grossl (não usar nesta pasta) — #{lin['grossl'].size}\n#{cab}\n#{lin['grossl'].join("\n")}\n"
File.write(File.join(__dir__, '..', 'referencia', 'catalogo_plugin.md'), out)
puts lin.transform_values(&:size)

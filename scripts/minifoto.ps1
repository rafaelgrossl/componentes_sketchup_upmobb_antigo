# Monta uma minifoto no padrao da pasta minifotos: 400x400, fundo branco, titulo em caixa alta
# (Gotham Bold Italic, 1a linha preta, demais cinza), logo da marca abaixo (-Logo), icone no canto superior
# direito e a foto do produto embaixo (sem margem branca). Padrao: regras/06_minifotos.md.
# Salva em JPG ajustando a qualidade para ficar perto de -Kb (padrao 60 KB).
#   powershell -File scripts/minifoto.ps1 -Foto produto.png -Titulo "CORREDIÇA|TELESCÓPICA|TT45 ONE-TOUCH" -Logo minifotos/_logos/fgvtn.png -Saida x.jpg
param(
  [Parameter(Mandatory)][string]$Foto,
  [Parameter(Mandatory)][string]$Titulo,          # linhas separadas por |
  [Parameter(Mandatory)][string]$Saida,
  [string]$Icone,                                 # minifoto existente de onde copiar o icone
  [int]$Lado = 400,
  [int]$Kb = 60,
  [string]$Fonte = 'Gotham',                      # familia instalada (nome exato); padrao: Gotham Bold Italic
  [string]$FonteArquivo,                          # .ttf sem instalar (ex.: GothamBoldItalic.ttf)
  [string]$Logo                                   # logo da marca abaixo do titulo (ex.: minifotos/_logos/fgvtn.png)
)
Add-Type -AssemblyName System.Drawing
# fonte do titulo: arquivo > instalada. Sem a fonte, para (nao troca por outra).
# Obs.: System.Drawing nao desenha .otf com contorno PostScript; a Gotham Bold Italic instalada e .ttf.
$estilo = [System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic
if ($FonteArquivo) {
  $pfc = New-Object System.Drawing.Text.PrivateFontCollection
  $pfc.AddFontFile((Resolve-Path $FonteArquivo).Path)
  $familia = $pfc.Families[0]
  # arquivo de um estilo so (ex.: GothamBoldItalic.ttf) aparece como Regular na colecao privada
  foreach ($e in $estilo, [System.Drawing.FontStyle]::Italic, [System.Drawing.FontStyle]::Regular) { if ($familia.IsStyleAvailable($e)) { $estilo = $e; break } }
} else {
  $familia = (New-Object System.Drawing.Text.InstalledFontCollection).Families | Where-Object { $_.Name -eq $Fonte } | Select-Object -First 1
  if (-not $familia) { throw "Fonte '$Fonte' nao encontrada (instale ou passe -FonteArquivo)." }
}
"fonte: $($familia.Name) ($estilo)"
if (-not $Icone) { $Icone = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\minifotos\gavetas_corredicas\corredica_telescopica.png' }
$Saida = [System.IO.Path]::GetFullPath($Saida)
$bmp = New-Object System.Drawing.Bitmap $Lado, $Lado
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$g.SmoothingMode = 'HighQuality'; $g.InterpolationMode = 'HighQualityBicubic'; $g.TextRenderingHint = 'AntiAliasGridFit'

# icone: recorte do canto superior direito de uma minifoto existente (256 px) -> escala
$ic = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Icone))
$k = $ic.Width / 256.0
$rIc = New-Object System.Drawing.Rectangle ([int](200 * $k)), 0, ([int](56 * $k)), ([int](56 * $k))
$t = [int]($Lado * 56 / 256)
$g.DrawImage($ic, (New-Object System.Drawing.Rectangle ($Lado - $t), 0, $t, $t), $rIc, 'Pixel')
$ic.Dispose()

# titulo (medidas das minifotos do usuario em Documents\upmobb, 400 px): 1a linha preta, demais cinza 46;
# letra com ~19 px de altura (27 px de fonte), uma linha a cada 25 px; mesmo tamanho em todas as linhas,
# reduz so se a mais longa nao couber ao lado do icone
$e = $Lado / 400.0
$corL1 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Black)
$corL2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 46, 46))
$sf = [System.Drawing.StringFormat]::GenericTypographic
$linhas = $Titulo -split '\|'
$tam = 27.0 * $e
while ($tam -gt 10) {
  $f = New-Object System.Drawing.Font($familia, $tam, $estilo, 'Pixel')
  $maior = ($linhas | ForEach-Object { $g.MeasureString($_, $f, 2000, $sf).Width } | Measure-Object -Maximum).Maximum
  $f.Dispose()
  if ($maior -le ($Lado - $t - 22 * $e)) { break } else { $tam -= 0.5 }
}
$f = New-Object System.Drawing.Font($familia, $tam, $estilo, 'Pixel')
$passo = $tam * 25.0 / 27.0
$y = 4.0 * $e
$i = 0
foreach ($l in $linhas) { $g.DrawString($l, $f, $(if ($i -eq 0) { $corL1 } else { $corL2 }), 18 * $e, $y, $sf); $y += $passo; $i++ }
$f.Dispose()
if ($Logo) {
  $lg = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Logo))
  $lw = $lg.Width * $e; $lh = $lg.Height * $e
  $g.DrawImage($lg, [single](14 * $e), [single]($y + 3 * $e), [single]$lw, [single]$lh)
  $y += 3 * $e
  $y += $lh
  $lg.Dispose()
}

# foto: corta a margem branca e encaixa na area abaixo do titulo, centralizada
$p0 = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Foto))
$p = New-Object System.Drawing.Bitmap $p0.Width, $p0.Height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$gp = [System.Drawing.Graphics]::FromImage($p); $gp.Clear([System.Drawing.Color]::White); $gp.DrawImage($p0, 0, 0, $p0.Width, $p0.Height); $gp.Dispose(); $p0.Dispose()
$bd = $p.LockBits((New-Object System.Drawing.Rectangle 0, 0, $p.Width, $p.Height), 'ReadOnly', $p.PixelFormat)
$buf = New-Object byte[] ($bd.Stride * $p.Height)
[System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $buf, 0, $buf.Length)
$p.UnlockBits($bd)
$x0 = $p.Width; $y0 = $p.Height; $x1 = 0; $y1 = 0
for ($yy = 0; $yy -lt $p.Height; $yy += 2) {
  $lin = $yy * $bd.Stride
  for ($xx = 0; $xx -lt $p.Width; $xx += 2) {
    $i = $lin + $xx * 3
    if ($buf[$i] -lt 235 -or $buf[$i + 1] -lt 235 -or $buf[$i + 2] -lt 235) {
      if ($xx -lt $x0) { $x0 = $xx }; if ($xx -gt $x1) { $x1 = $xx }; if ($yy -lt $y0) { $y0 = $yy }; if ($yy -gt $y1) { $y1 = $yy }
    }
  }
}
if ($x1 -gt $x0) { $rp = New-Object System.Drawing.Rectangle $x0, $y0, ($x1 - $x0 + 2), ($y1 - $y0 + 2); $p2 = $p.Clone($rp, $p.PixelFormat); $p.Dispose(); $p = $p2 }
$topo = [math]::Max($y + 8, $t + 4)
$aw = $Lado - 20; $ah = $Lado - $topo - 10
$s = [math]::Min($aw / $p.Width, $ah / $p.Height)
$pw = [int]($p.Width * $s); $ph = [int]($p.Height * $s)
$g.DrawImage($p, [int](($Lado - $pw) / 2), [int]($topo + ($ah - $ph) / 2), $pw, $ph)
$p.Dispose(); $g.Dispose()

# JPG: maior qualidade que fica ate ~Kb
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$melhor = $null
foreach ($q in 98, 95, 92, 90, 88, 85, 82, 80, 75, 70, 65, 60) {
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$q)
  $ms = New-Object System.IO.MemoryStream
  $bmp.Save($ms, $enc, $ep)
  if ($ms.Length -le $Kb * 1024 * 1.1) { $melhor = $ms; $mq = $q; break }
  $melhor = $ms; $mq = $q
}
[System.IO.File]::WriteAllBytes($Saida, $melhor.ToArray())
$bmp.Dispose()
"{0}  q={1}  {2:N0} KB" -f $Saida, $mq, ($melhor.Length / 1024)

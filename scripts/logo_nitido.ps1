# Deixa nitido um logo de cor chapada sobre branco, recortado de uma miniatura pequena:
# amplia (bicubico, sem vazar a borda) e aplica curva de contraste: o que e quase branco vira branco, o miolo
# vira a cor do logo (a mais escura do recorte) e a borda fica numa rampa curta (antisserrilhado).
# Uso: powershell -File scripts/logo_nitido.ps1 -Img mini.png -X 12 -Y 51 -W 93 -H 19 -Escala 8 -Saida _logos/x.png [-Largura 190]
param([string]$Img, [int]$X, [int]$Y, [int]$W, [int]$H, [int]$Escala = 8, [string]$Saida, [int]$Largura = 190,
      [int]$Branco = 225, [int]$Cheio = 150)
Add-Type -AssemblyName System.Drawing
$s0 = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Img))
$s = $s0.Clone((New-Object System.Drawing.Rectangle $X, $Y, $W, $H), [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$s0.Dispose()
# cor do logo = media dos pixels bem escuros (soma RGB abaixo de 60% da mais escura + 120)
$min = 765; for ($i = 0; $i -lt $W; $i++) { for ($j = 0; $j -lt $H; $j++) { $c = $s.GetPixel($i, $j); $t = $c.R + $c.G + $c.B; if ($t -lt $min) { $min = $t } } }
$r = 0; $g_ = 0; $b = 0; $n = 0
for ($i = 0; $i -lt $W; $i++) { for ($j = 0; $j -lt $H; $j++) { $c = $s.GetPixel($i, $j); if (($c.R + $c.G + $c.B) -le ($min + 60)) { $r += $c.R; $g_ += $c.G; $b += $c.B; $n++ } } }
$r = [int]($r / $n); $g_ = [int]($g_ / $n); $b = [int]($b / $n)
$bw = $W * $Escala; $bh = $H * $Escala
$big = New-Object System.Drawing.Bitmap $bw, $bh, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$gb = [System.Drawing.Graphics]::FromImage($big); $gb.InterpolationMode = 'HighQualityBicubic'; $gb.PixelOffsetMode = 'HighQuality'
$ia = New-Object System.Drawing.Imaging.ImageAttributes; $ia.SetWrapMode('TileFlipXY')
$gb.DrawImage($s, (New-Object System.Drawing.Rectangle 0, 0, $bw, $bh), 0, 0, $W, $H, 'Pixel', $ia); $gb.Dispose(); $s.Dispose()
# curva: lum >= Branco -> branco; lum <= Cheio -> cor do logo; entre -> rampa
$bd = $big.LockBits((New-Object System.Drawing.Rectangle 0, 0, $bw, $bh), 'ReadWrite', $big.PixelFormat)
$buf = New-Object byte[] ($bd.Stride * $bh); [System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $buf, 0, $buf.Length)
for ($j = 0; $j -lt $bh; $j++) { for ($i = 0; $i -lt $bw; $i++) {
  $o = $j * $bd.Stride + $i * 3; $l = ($buf[$o] + $buf[$o + 1] + $buf[$o + 2]) / 3.0
  $a = [math]::Min(1.0, [math]::Max(0.0, ($Branco - $l) / ($Branco - $Cheio)))
  $buf[$o] = [byte](255 - $a * (255 - $b)); $buf[$o + 1] = [byte](255 - $a * (255 - $g_)); $buf[$o + 2] = [byte](255 - $a * (255 - $r)) } }
[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $bd.Scan0, $buf.Length); $big.UnlockBits($bd)
# reduz para a largura final (com margem branca de 2 px), alta qualidade
$lw = $Largura; $lh = [int][math]::Round($bh * ($Largura - 4) / $bw) + 6
$out = New-Object System.Drawing.Bitmap $lw, $lh
$go = [System.Drawing.Graphics]::FromImage($out); $go.Clear([System.Drawing.Color]::White)
$go.InterpolationMode = 'HighQualityBicubic'; $go.PixelOffsetMode = 'HighQuality'; $go.SmoothingMode = 'HighQuality'
$go.DrawImage($big, (New-Object System.Drawing.Rectangle 2, 3, ($lw - 4), ($lh - 6)), 0, 0, $bw, $bh, 'Pixel', $ia); $go.Dispose(); $big.Dispose()
if (-not [System.IO.Path]::IsPathRooted($Saida)) { $Saida = Join-Path (Get-Location) $Saida }   # aceita caminho absoluto
$out.Save($Saida, [System.Drawing.Imaging.ImageFormat]::Png); $out.Dispose()
"logo: $Saida ${lw}x${lh}  cor $r,$g_,$b"

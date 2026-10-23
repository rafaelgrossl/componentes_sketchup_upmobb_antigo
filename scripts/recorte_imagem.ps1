# Recorta um retangulo (px) de uma imagem: -Img -Saida -X -Y -W -H
# -Branco "x,y,w,h;x,y,w,h": cobre de branco areas do recorte (texto/selo da pagina que caiu na foto).
# -Clarear 1.08: multiplica as cores (fundo cinza claro da foto vira branco puro, igual ao da minifoto).
param([string]$Img, [string]$Saida, [int]$X, [int]$Y, [int]$W, [int]$H, [string]$Branco, [single]$Clarear = 1.0)
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile($Img)
$c = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$gc = [System.Drawing.Graphics]::FromImage($c)
$gc.Clear([System.Drawing.Color]::White)
$ia = New-Object System.Drawing.Imaging.ImageAttributes
$cm = New-Object System.Drawing.Imaging.ColorMatrix
$cm.Matrix00 = $Clarear; $cm.Matrix11 = $Clarear; $cm.Matrix22 = $Clarear
$ia.SetColorMatrix($cm)
$gc.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, $W, $H), $X, $Y, $W, $H, [System.Drawing.GraphicsUnit]::Pixel, $ia)
$gc.Dispose()
if ($Branco) {
  $g = [System.Drawing.Graphics]::FromImage($c)
  foreach ($b in $Branco -split ';') { $v = $b -split ',' | ForEach-Object { [int]$_ }; $g.FillRectangle([System.Drawing.Brushes]::White, $v[0], $v[1], $v[2], $v[3]) }
  $g.Dispose()
}
$c.Save($Saida, [System.Drawing.Imaging.ImageFormat]::Png)
$c.Dispose(); $src.Dispose()

param([int]$Minutos = 20, [string]$Log)
# Vigia: se o DC abrir "Parece que esta operacao esta demorando bastante. Deseja continuar?", responde Sim e anota a hora.
Add-Type -AssemblyName UIAutomationClient; Add-Type -AssemblyName UIAutomationTypes
$fim = (Get-Date).AddMinutes($Minutos)
$texto = 'Parece que esta operação está demorando bastante. Deseja continuar?'
while ((Get-Date) -lt $fim) {
  $p = Get-Process -Name SketchUp -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($p) {
    $raiz = [System.Windows.Automation.AutomationElement]::RootElement
    $cond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty, $p.Id)
    foreach ($j in $raiz.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)) {
      $t = $j.FindFirst([System.Windows.Automation.TreeScope]::Descendants, (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $texto)))
      if ($t) {
        $sim = $j.FindFirst([System.Windows.Automation.TreeScope]::Descendants, (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, 'Sim')))
        $sim.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
        Add-Content -Path $Log -Value ("caixa 'demorando' respondida Sim em " + (Get-Date -Format 'HH:mm:ss'))
      }
    }
  }
  Start-Sleep -Milliseconds 700
}

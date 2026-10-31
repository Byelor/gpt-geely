# Правка легаси audio_effects.conf под ViPER (pull -> правка -> push).
# Удаляет плоские блоки «имя { ... }» с v4a в теле и вставляет записи
# v4a_re / v4a_standard_re сразу после строк «libraries {» и «effects {».
param(
    [Parameter(Mandatory=$true)][string]$In,
    [Parameter(Mandatory=$true)][string]$Out,
    [Parameter(Mandatory=$true)][string]$LibDir
)
$ErrorActionPreference = 'Stop'

$text = [IO.File]::ReadAllText($In)

$text = [regex]::Replace($text, '(?ms)^[ \t]*[\w.\-]+[ \t]*\{[^{}]*\}[ \t]*\r?\n?', {
    param($m)
    if ($m.Value -match '(?i)v4a') { '' } else { $m.Value }
})

$lib = "  v4a_re {`r`n    path $LibDir/libv4a_re.so`r`n  }`r`n"
$eff = "  v4a_standard_re {`r`n    library v4a_re`r`n    uuid 90380da3-8536-4744-a6a3-5731970e640f`r`n  }`r`n"

$text = [regex]::Replace($text, '(?m)^([ \t]*libraries[ \t]*\{[^\r\n]*\r?\n)', { param($m) $m.Value + $lib })
$text = [regex]::Replace($text, '(?m)^([ \t]*effects[ \t]*\{[^\r\n]*\r?\n)', { param($m) $m.Value + $eff })

[IO.File]::WriteAllText($Out, $text, (New-Object System.Text.UTF8Encoding $false))

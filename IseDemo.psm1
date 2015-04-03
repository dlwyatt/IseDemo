function Start-IseDemo
{
    [CmdletBinding()]
    param (
        [string] $Path,
        [switch] $ShowHints
    )

    if (-not $Path)
    {
        $Path = $PSCmdlet.SessionState.Path.CurrentFileSystemLocation
    }

    $script:CurrentIndex = 0
    $script:BasePath = $Path
    $script:ShowHints = [bool]$ShowHints

    Invoke-NextIseDemo
}

function Invoke-NextIseDemo
{
    if ($null -eq $Script:BasePath)
    {
        throw 'Call Start-IseDemo before Invoke-NextIseDemo'
    }

    LoadSlide ($Script:CurrentIndex + 1)
}

function Invoke-PreviousIseDemo
{
    if ($null -eq $Script:BasePath)
    {
        throw 'Call Start-IseDemo before Invoke-PreviousIseDemo'
    }

    LoadSlide ($Script:CurrentIndex - 1)
}

function LoadSlide($Index)
{
    ClearCurrentPowerShellTab

    if ($Index -le 0) {
        Write-Warning 'Beginning of Demo.'
        return
    }

    $slidePath = Join-Path $script:BasePath $Index

    if (Test-Path -LiteralPath $slidePath -PathType Container)
    {
        $Script:CurrentIndex = $Index

        $Script:OpenFiles = @(
            Get-ChildItem $slidePath\* -File -Exclude Hint.txt |
            Sort-Object -Property { ($_.BaseName -replace '\D') -as [int] } |
            ForEach-Object {
                $psise.CurrentPowerShellTab.Files.Add($_.FullName)
            }
        )

        if ($Script:ShowHints)
        {
            ShowHints
        }
    }
    else
    {
        Write-Warning 'End of Demo.'
        return
    }
}
function ClearCurrentPowerShellTab
{
    foreach ($iseFile in $script:OpenFiles)
    {
        if (-not $psISE.CurrentPowerShellTab.Files.Contains($iseFile))
        {
            continue
        }

        $psISE.CurrentPowerShellTab.Files.Remove($iseFile, $true)
    }

    $script:OpenFiles = @()
}

function ShowHints
{
    $nextPath = Join-Path $Script:BasePath "$($script:CurrentIndex + 1)\Hint.txt"

    if (Test-Path -LiteralPath $nextPath -PathType Leaf)
    {
        Write-Host -ForegroundColor Cyan "Next: $(Get-Content $nextPath)"
    }
}

$prevGesture = New-Object System.Windows.Input.KeyGesture([System.Windows.Input.Key]::PageUp,   [System.Windows.Input.ModifierKeys]::Control)
$nextGesture = New-Object System.Windows.Input.KeyGesture([System.Windows.Input.Key]::PageDown, [System.Windows.Input.ModifierKeys]::Control)

$existingPrevGesture = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus |
                       Where-Object {
                           $_.Shortcut -is [System.Windows.Input.KeyGesture] -and
                           $_.Shortcut.Key -eq $prevGesture.Key -and
                           $_.Shortcut.Modifiers -eq $prevGesture.Modifiers
                       }

$existingNextGesture = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus |
                       Where-Object {
                           $_.Shortcut -is [System.Windows.Input.KeyGesture] -and
                           $_.Shortcut.Key -eq $nextGesture.Key -and
                           $_.Shortcut.Modifiers -eq $nextGesture.Modifiers
                       }

if ($null -eq $existingPrevGesture)
{
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Previous ISE Demo Slide', {Invoke-PreviousIseDemo}, $prevGesture)
}

if ($null -eq $existingNextGesture)
{
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Next ISE Demo Slide', {Invoke-NextIseDemo}, $nextGesture)
}

Set-Alias -Name sid -Value Start-IseDemo
Set-Alias -Name nid -Value Invoke-NextIseDemo
Set-Alias -Name pid -Value Invoke-PreviousIseDemo

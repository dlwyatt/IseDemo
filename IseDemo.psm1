#requires -Version 3.0

if ($null -eq $psISE -or $psISE.GetType().FullName -ne 'Microsoft.PowerShell.Host.ISE.ObjectModelRoot')
{
    throw 'The IseDemo module only works in the PowerShell ISE.'
}

function Start-IseDemo
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Path,

        [switch] $ShowHints
    )

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
    if ($Index -le 0) {
        Write-Warning 'Beginning of Demo.'
        return
    }

    $slidePath = Join-Path $script:BasePath $Index

    if (Test-Path -LiteralPath $slidePath -PathType Container)
    {
        ClearCurrentPowerShellTab

        $Script:CurrentIndex = $Index

        Get-ChildItem $slidePath\* -File -Exclude Hint.txt |
        Sort-Object -Property { $_.BaseName -as [int] } |
        ForEach-Object {
            $null = $psise.CurrentPowerShellTab.Files.Add($_.FullName)
        }

        if ($psise.CurrentPowerShellTab.Files.Count -gt 0)
        {
            $null = $psise.CurrentPowerShellTab.Files.SetSelectedFile($psise.CurrentPowerShellTab.Files[0])
        }

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
    foreach ($iseFile in $psISE.CurrentPowerShellTab.Files)
    {
        if (-not $iseFile.IsSaved) { $iseFile.SaveAs("$env:temp\Discard.ps1") }
    }

    $psISE.CurrentPowerShellTab.Files.Clear()
}

function ShowHints
{
    $currentPath = Join-Path $Script:BasePath "$script:CurrentIndex\Hint.txt"
    $prevPath = Join-Path $Script:BasePath "$($script:CurrentIndex - 1)\Hint.txt"
    $nextPath = Join-Path $Script:BasePath "$($script:CurrentIndex + 1)\Hint.txt"

    if ($prevPath -gt 0 -and (Test-Path -LiteralPath $prevPath -PathType Leaf))
    {
        Write-Host "Previous: $(Get-Content $prevPath)"
    }

    if (Test-Path -LiteralPath $currentPath -PathType Leaf)
    {
        Write-Host "Current : $(Get-Content $currentPath)"
    }

    if (Test-Path -LiteralPath $nextPath -PathType Leaf)
    {
        Write-Host "Next    : $(Get-Content $nextPath)"
    }
}

$prevGesture = New-Object System.Windows.Input.KeyGesture([System.Windows.Input.Key]::Left, ([System.Windows.Input.ModifierKeys]::Control -bor [System.Windows.Input.ModifierKeys]::Alt))
$nextGesture = New-Object System.Windows.Input.KeyGesture([System.Windows.Input.Key]::Right, ([System.Windows.Input.ModifierKeys]::Control -bor [System.Windows.Input.ModifierKeys]::Alt))

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

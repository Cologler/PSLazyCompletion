$profileLocation = [System.IO.Path]::GetDirectoryName($PROFILE);
$completionsPath = [System.IO.Path]::Combine($profileLocation, "Completions");

New-Variable -Scope global -Name CompletionsDir -Value $completionsPath

# copied from https://gist.github.com/indented-automation/26c637fb530c4b168e62c72582534f5b.

$getExecutionContextFromTLS = [PowerShell].Assembly.GetType('System.Management.Automation.Runspaces.LocalPipeline').GetMethod(
    'GetExecutionContextFromTLS',
    [System.Reflection.BindingFlags]'Static,NonPublic'
)
$internalExecutionContext = $getExecutionContextFromTLS.Invoke(
    $null,
    [System.Reflection.BindingFlags]'Static, NonPublic',
    $null,
    $null,
    $psculture
)

$argumentCompletersProperty = $internalExecutionContext.GetType().GetProperty(
    'NativeArgumentCompleters',
    [System.Reflection.BindingFlags]'NonPublic, Instance'
)

if (Test-Path $completionsPath -PathType Container) {
    Get-ChildItem -Path $completionsPath -Filter *.ps1 |
    ForEach-Object {
        $baseName = $_.BaseName;
        $scriptPath = [System.IO.Path]::Combine($completionsPath, "$baseName.ps1")
        Register-ArgumentCompleter -Native -CommandName $baseName -ScriptBlock {
            . $scriptPath

            $argumentCompleters = $argumentCompletersProperty.GetGetMethod($true).Invoke(
                $internalExecutionContext,
                [System.Reflection.BindingFlags]'Instance, NonPublic, GetProperty',
                $null,
                @(),
                $psculture
            )

            if ($argumentCompleters.ContainsKey($baseName)) {
                $scriptBlock = $argumentCompleters[$baseName];
                return Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $args
            }
        }.GetNewClosure() # make sure local variables in the context were copied
    }
}

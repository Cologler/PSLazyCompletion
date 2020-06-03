# PSLazyCompletion

*Lazy load completions for powershell.*

## WHY and HOW

### Speedup load profile

- Import too many completion modules in `$profile` may cause performance problem.
- You won't run all commands in every session so why do you load unnecessary completions everytime?

PSLazyCompletion only load completion script when you need it.

### Keep `$profile` simple

All completion scripts are save in a standalone directory, you only need to add one line in `$profile`:

``` ps1
Import-Module PSLazyCompletion
```

For example, if your `$profile` file was in directory `~\Documents\PowerShell\`, then PSLazyCompletion will use `~\Documents\PowerShell\Completions` to load completion scripts.

## Example

### dotnet

As https://docs.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete said:

> Add the following code to your profile

To use PSLazyCompletion you can **add following code to your `~\Documents\PowerShell\Completions\dotnet.ps1`**.

``` ps1
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
     param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
         }
 }
```

### rustup

rustup use `rustup completions powershell` to generate completions script, so you can just run:

``` ps1
rustup completions powershell > "~\Documents\PowerShell\Completions\rustup.ps1"
```

PSLazyCompletion also add a global variable `$CompletionsDir`,
so you can change it to:

``` ps1
rustup completions powershell > "$CompletionsDir\rustup.ps1"
```

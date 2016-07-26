[![Build status](https://ci.appveyor.com/api/projects/status/sg718xgnvaifasch/branch/master?svg=true)](https://ci.appveyor.com/project/PlagueHO/systemlocale/branch/master)

# SystemLocale

The **SystemLocaleDsc** module contains the **SystemLocale** DSC resource for setting the system locale on a Windows machine.
To get a list of valid Windows System Locales use the command:
`[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).name`

If the System Locale is changed by this resource, it will require the node to reboot.
If the LCM is not configured to allow restarting, the configration will not be able to be

## Contributing

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

### SystemLocale

* **SystemLocale**: Specifies the System Locale. To discover all valid System Locales for this property, use this PowerShell command: `[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).name`
* **IsSingleInstance**: Specifies if the resource is a single instance, the value must be 'Yes'

## Versions

### Unreleased

### 1.0.0.0

* SystemLocale: Initial release.

## Examples

### Setting the System Local

Set the System Locale to 'ja-JP'

```powershell
Configuration SetSystemLocale
{
   Param
   (
       [String[]] $NodeName = $env:COMPUTERNAME,

       [Parameter(Mandatory = $true)]
       [ValidateNotNullorEmpty()]
       [String] $SystemLocale
   )

   Import-DSCResource -ModuleName SystemLocaleDsc

   Node $NodeName
   {
        SystemLocale SystemLocaleExample
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $SystemLocale
        }
   }
}

SetSystemLocale -NodeName 'localhost' -SystemLocale 'ja-JP'
Start-DscConfiguration -Path .\SetSystemLocale -Wait -Verbose -Force
```

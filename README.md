[![Build status](https://ci.appveyor.com/api/projects/status/6fc4k4ef9isqsu6m/branch/dev?svg=true)](https://ci.appveyor.com/project/PlagueHO/systemlocaledsc/branch/dev)

# SystemLocale

The **SystemLocaleDsc** module contains the **SystemLocale** DSC resource for setting the system locale on a Windows machine.
To get a list of valid Windows System Locales use the command:
`[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).name`

If the System Locale is changed by this resource, it will require the node to reboot.
If the LCM is not configured to allow restarting, the configuration will not be able to be applied
until a manual restart occurs.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

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

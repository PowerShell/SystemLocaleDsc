# SystemLocaleDsc

The **SystemLocaleDsc** module contains the **SystemLocale** DSC resource for
setting the system locale on a Windows machine. To get a list of valid Windows
System Locales use the command:
`[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).name`

If the System Locale is changed by this resource, it will require the node to reboot.
If the LCM is not configured to allow restarting, the configuration will not be
able to be applied until a manual restart occurs.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any
additional questions or comments.

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/i9vo21txuwm2hjk7/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/SystemLocaleDsc/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/SystemLocaleDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/SystemLocaleDsc/branch/master)

This is the branch containing the latest release - no contributions should be made
directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/i9vo21txuwm2hjk7/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/SystemLocaleDsc/branch/dev)
[![codecov](https://codecov.io/gh/PowerShell/SystemLocaleDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/PowerShell/SystemLocaleDsc/branch/dev)

This is the development branch to which contributions should be proposed by contributors
as pull requests. This development branch will periodically be merged to the master
branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

### SystemLocale

* **SystemLocale**: Specifies the System Locale. To discover all valid System
  Locales for this property, use this PowerShell command: `[System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).name`
* **IsSingleInstance**: Specifies if the resource is a single instance, the value
  must be 'Yes'

### SystemLocale Examples

* [Set the System Locale of the computer](/Examples/Resources/SystemLocaleDsc/1-SetSystemLocale.ps1)

## Versions

### Unreleased

### 1.2.0.0

* Added resource helper module.
* Change examples to meet HQRM standards and optin to Example validation
  tests.
* Replaced examples in README.MD to links to Example files.
* Added the VS Code PowerShell extension formatting settings that cause PowerShell
  files to be formatted as per the DSC Resource kit style guidelines.
* Opted into Common Tests 'Validate Module Files' and 'Validate Script Files'.
* Converted files with UTF8 with BOM over to UTF8.
* Updated Year to 2017 in License and Manifest.
* Added .github support files:
  * CONTRIBUTING.md
  * ISSUE_TEMPLATE.md
  * PULL_REQUEST_TEMPLATE.md
* Resolved all PSScriptAnalyzer warnings and style guide warnings.

### 1.1.0.0

* Fix AppVeyor.yml build process.
* Convert Get-TargetResource to output IsSingleInstance value passed in as parameter.

### 1.0.0.0

* SystemLocaleDsc: Initial release.

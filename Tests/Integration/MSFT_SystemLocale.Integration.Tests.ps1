$Global:DSCModuleName      = 'SystemLocaleDsc'
$Global:DSCResourceName    = 'MSFT_SystemLocale'

#region HEADER
# Integration Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Integration
#endregion

# Store the test machine system locale
$CurrentSystemLocale = (Get-WinSystemLocale).Name
# Change the current system locale so that a complete test occurs.
Set-WinSystemLocale -SystemLocale 'kl-GL'

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($Global:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Global:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {
                $_.ConfigurationName -eq "$($Global:DSCResourceName)_Config"
            }
            # A reboot would need to occur before this node can be bought into alignment
            # $current.SystemLocale     | Should Be $TestSystemLocale.SystemLocale
            $current.IsSingleInstance | Should Be $TestSystemLocale.IsSingleInstance
        }
    }
    #endregion
}
finally
{
    # Restore the test machine system locale
    Set-WinSystemLocale -SystemLocale $CurrentSystemLocale

    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}

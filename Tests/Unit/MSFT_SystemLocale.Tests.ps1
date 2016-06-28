$Global:DSCModuleName      = 'SystemLocale'
$Global:DSCResourceName    = 'MSFT_SystemLocale'

#region HEADER
# Unit Test Template Version: 1.1.0
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
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $Global:DSCResourceName {
        $TestSystemLocale = 'en-US'
        $MockedSystemLocale = @{
            LCID        = '1033'
            Name        = $TestSystemLocale
            DisplayName = 'English (United States)'
        }
        $TestAltSystemLocale = 'en-UK'

        Describe 'Schema' {
            it 'IsSingleInstance should be mandatory with one value.' {
                $SystemLocaleResource = Get-DscResource -Name SystemLocale
                $SystemLocaleResource.Properties.Where{$_.Name -eq 'IsSingleInstance'}.IsMandatory | should be $true
                $SystemLocaleResource.Properties.Where{$_.Name -eq 'IsSingleInstance'}.Values | should be 'Yes'
            }
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            Mock -CommandName Get-WinSystemLocale -MockWith { $MockedSystemLocale }

            Context 'System Locale is the desired state' {
                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -SystemLocale $TestSystemLocale `
                            -IsSingleInstance 'Yes'
                    } | Should Not Throw
                }

                It 'Should return hashtable with Key SystemLocale'{
                    $SystemLocale.ContainsKey('SystemLocale') | Should Be $true
                }

                It "Should return hashtable with Value that matches '$TestSystemLocale'" {
                    $SystemLocale.SystemLocale = $TestSystemLocale
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            Mock -CommandName Set-WinSystemLocale
            Mock -CommandName Get-WinSystemLocale -MockWith { $MockedSystemLocale }

            Context 'System Locale is the desired state' {
                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -SystemLocale $TestSystemLocale `
                            -IsSingleInstance 'Yes'
                    } | Should Not Throw
                }
                It 'Should not call Set-WinSystemLocale' {
                    Assert-MockCalled `
                        -CommandName Set-WinSystemLocale `
                        -Exactly 0
                }
            }

            Context 'System Locale is not in the desired state' {
                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -SystemLocale $TestAltSystemLocale `
                            -IsSingleInstance 'Yes'
                    } | Should Not Throw
                }
                It 'Should call Set-WinSystemLocale' {
                    Assert-MockCalled `
                        -CommandName Set-WinSystemLocale `
                        -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Mock -CommandName Get-WinSystemLocale -MockWith { $MockedSystemLocale }

            It 'Should return true when Test is passed System Locale thats already set' {
                Test-TargetResource `
                    -TimeZone 'Pacific Standard Time' `
                    -IsSingleInstance 'Yes' | Should Be $true
            }

            It 'Should return false when Test is passed Time Zone that is not set' {
                Test-TargetResource `
                    -TimeZone 'Eastern Standard Time' `
                    -IsSingleInstance 'Yes' | Should Be $false
            }
        }
    } #end InModuleScope $DSCResourceName
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}

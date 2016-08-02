$Global:DSCModuleName      = 'SystemLocaleDsc'
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
        $TestAltSystemLocale = 'en-AU'
        $BadSystemLocale = 'zzz-ZZZ'

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
                $SystemLocale = Get-TargetResource `
                    -SystemLocale $TestSystemLocale `
                    -IsSingleInstance 'Yes'

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

            It 'Should throw an InvalidSystemLocaleError exception' {
                $errorId = 'InvalidSystemLocaleError'
                $errorMessage = ($LocalizedData.InvalidSystemLocaleError -f $BadSystemLocale)
                $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                $exception = New-Object `
                    -TypeName System.InvalidOperationException `
                    -ArgumentList $errorMessage
                $errorRecord = New-Object `
                    -TypeName System.Management.Automation.ErrorRecord `
                    -ArgumentList $exception, $errorId, $errorCategory, $null

                { Test-TargetResource `
                    -SystemLocale $BadSystemLocale `
                    -IsSingleInstance 'Yes' } | Should Throw $errorRecord
            }

            It 'Should return true when Test is passed System Locale thats already set' {
                Test-TargetResource `
                    -SystemLocale $TestSystemLocale `
                    -IsSingleInstance 'Yes' | Should Be $true
            }

            It 'Should return false when Test is passed System Locale that is not set' {
                Test-TargetResource `
                    -SystemLocale $TestAltSystemLocale `
                    -IsSingleInstance 'Yes' | Should Be $false
            }
        }

        Describe "$($Global:DSCResourceName)\Test-SystemLocaleValue" {
            It 'Should return true when a valid System Locale is passed' {
                Test-SystemLocaleValue `
                    -SystemLocale $TestSystemLocale | Should Be $true
            }

            It 'Should return false when an invalid System Locale is passed' {
                Test-SystemLocaleValue `
                    -SystemLocale $BadSystemLocale | Should Be $false
            }
        }

        Describe "$($Global:DSCResourceName)\New-TerminatingError" {

            Context 'Create a TestError Exception' {

                It 'should throw an TestError exception' {
                    $errorId = 'TestError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = 'Test Error Message'
                    $exception = New-Object `
                        -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object `
                        -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { New-TerminatingError `
                        -ErrorId $errorId `
                        -ErrorMessage $errorMessage `
                        -ErrorCategory $errorCategory } | Should Throw $errorRecord
                }
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

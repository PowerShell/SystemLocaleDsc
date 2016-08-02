#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_SystemLocale.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    #fallback to en-US
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_SystemLocale.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance,

        [parameter(Mandatory = $true)]
        [String] $SystemLocale
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.GettingSystemLocaleMessage)
        ) -join '' )

    # Get the current System Locale
    $CurrentSystemLocale = Get-WinSystemLocale `
        -ErrorAction Stop

    # Generate the return object.
    $ReturnValue = @{
        IsSingleInstance = 'Yes'
        SystemLocale     = $CurrentSystemLocale.Name
    }

    return $ReturnValue
} # Get-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance,

        [parameter(Mandatory = $true)]
        [String] $SystemLocale
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingSystemLocaleMessage)
        ) -join '' )

    # Get the current System Locale
    $CurrentSystemLocale = Get-WinSystemLocale `
        -ErrorAction Stop

    if ($CurrentSystemLocale.Name -ne $SystemLocale)
    {
        Set-WinSystemLocale `
            -SystemLocale $SystemLocale `
            -ErrorAction Stop

        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SystemLocaleUpdatedMessage)
            ) -join '' )

        $global:DSCMachineStatus = 1

        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.RestartRequiredMessage)
            ) -join '' )
    }
} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance,

        [parameter(Mandatory = $true)]
        [String] $SystemLocale
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestingSystemLocaleMessage)
        ) -join '' )


    if (-not (Test-SystemLocaleValue -SystemLocale $SystemLocale)) {
        New-TerminatingError `
            -errorId 'InvalidSystemLocaleError' `
            -errorMessage ($LocalizedData.InvalidSystemLocaleError -f $SystemLocale) `
            -errorCategory InvalidArgument
    } # if

    # Get the current System Locale
    $CurrentSystemLocale = Get-WinSystemLocale `
        -ErrorAction Stop

    if ($CurrentSystemLocale.Name -ne $SystemLocale)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SystemLocaleParameterNeedsUpdateMessage -f `
                $CurrentSystemLocale.Name,$SystemLocale)
        ) -join '' )
        return $false
    }
    return $true
} # Test-TargetResource

# Helper Functions
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String] $ErrorId,

        [Parameter(Mandatory)]
        [String] $ErrorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory] $ErrorCategory
    )

    $exception = New-Object `
        -TypeName System.InvalidOperationException `
        -ArgumentList $errorMessage
    $errorRecord = New-Object `
        -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $errorId, $errorCategory, $null
    $PSCmdlet.ThrowTerminatingError($errorRecord)
}

<#
.SYNOPSIS
 Checks the provided System Locale against the list of valid cultures.
#>
function Test-SystemLocaleValue
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [String] $SystemLocale
    )
    $ValidCultures = [System.Globalization.CultureInfo]::GetCultures(`
        [System.Globalization.CultureTypes]::AllCultures`
        ).name
    return ($SystemLocale -in $ValidCultures)
}

Export-ModuleMember -Function *-TargetResource

#region LocalizedData
$Culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath $PSUICulture))
{
    $Culture = $PSUICulture
}
Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename MSFT_SystemLocale.psd1 `
    -BaseDirectory $PSScriptRoot `
    -UICulture $Culture
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

Export-ModuleMember -Function *-TargetResource

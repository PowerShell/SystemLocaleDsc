Configuration SetSystemLocale
{
   Param
   (
       [String[]] $NodeName = $env:COMPUTERNAME,

       [Parameter(Mandatory = $true)]
       [ValidateNotNullorEmpty()]
       [String] $SystemLocale
   )

   Import-DSCResource -ModuleName SystemLocale

   Node $NodeName
   {
        SystemLocale SystemLocaleExample
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $SystemLocale
        }
   }
}

SystemLocale -NodeName 'localhost' -SystemLocale 'ja-JP'
Start-DscConfiguration -Path .\SystemLocale -Wait -Verbose -Force

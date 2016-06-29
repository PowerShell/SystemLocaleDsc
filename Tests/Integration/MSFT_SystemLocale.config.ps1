$TestSystemLocale = [PSObject]@{
    SystemLocale     = 'fr-FR'
    IsSingleInstance = 'Yes'
}

configuration MSFT_SystemLocale_Config {
    Import-DscResource -ModuleName SystemLocale
    node localhost {
        SystemLocale Integration_Test {
            SystemLocale     = $TestSystemLocale.SystemLocale
            IsSingleInstance = $TestSystemLocale.IsSingleInstance
        }
    }
}

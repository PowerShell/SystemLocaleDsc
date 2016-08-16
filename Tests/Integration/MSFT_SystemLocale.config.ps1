$TestSystemLocale = @{
    SystemLocale     = 'fr-FR'
    IsSingleInstance = 'Yes'
}

configuration MSFT_SystemLocale_Config {
    Import-DscResource -ModuleName SystemLocaleDsc
    node localhost {
        SystemLocale Integration_Test {
            SystemLocale     = $TestSystemLocale.SystemLocale
            IsSingleInstance = $TestSystemLocale.IsSingleInstance
        }
    }
}

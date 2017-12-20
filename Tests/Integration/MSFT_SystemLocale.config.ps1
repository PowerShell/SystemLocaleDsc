configuration MSFT_SystemLocale_Config {
    Import-DscResource -ModuleName SystemLocaleDsc

    node localhost {
        SystemLocale Integration_Test {
            SystemLocale     = $Node.SystemLocale
            IsSingleInstance = $Node.IsSingleInstance
        }
    }
}

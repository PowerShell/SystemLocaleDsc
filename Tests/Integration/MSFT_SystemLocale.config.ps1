$TestSystemLocale = [PSObject]@{
    SystemLocale     = 'en-US'
    IsSingleInstance = 'Yes'
}

configuration xSystemLocale_Config {
    Import-DscResource -ModuleName SystemLocale
    node localhost {
        SystemLocale Integration_Test {
            SystemLocale     = $TestSystemLocale.SystemLocale
            IsSingleInstance = $TestSystemLocale.IsSingleInstance
        }
    }
}

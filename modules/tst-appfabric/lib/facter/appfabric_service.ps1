function Service-Installed()
{
$Service=Get-Service | Where-Object { $_.Name -eq "AppFabricCachingService" }
if ($Service -ne $null)
{
	write-host "true"
}
else 
	{		
	Write-host "false"
    }
}

Function Service-Running()
{
$Service=Get-Service | Where-Object { $_.Name -eq "AppFabricCachingService" }
if ($Service.status -eq "Running")
{
	write-host "true"
}
else 
	{		
	Write-host "false"
    }
}

# SIG # Begin signature block
# MIIERQYJKoZIhvcNAQcCoIIENjCCBDICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3wFp8/I/kIQ5aogRNmYL7KT4
# c6egggJMMIICSDCCAbWgAwIBAgIQMqQVZtMErbpHeYlbNCUYjjAJBgUrDgMCHQUA
# MC8xLTArBgNVBAMTJGNvbVNjb3JlIFBvd2VyU2hlbGwgQ2VydGlmaWNhdGUgUm9v
# dDAeFw0xMjA1MTEyMTE5MThaFw0zOTEyMzEyMzU5NTlaMCMxITAfBgNVBAMTGGNv
# bVNjb3JlIFBvd2VyU2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkC
# gYEA09Vva31IPSXQl765974dvdlyjKLzHkrD1XyZD8vnDjxjfBIRLElcmHiSJJKV
# eQeNHJRWyPkCg0JYAe0Y/0TprvIyNxCDsEg/c6w7UZXQlQ+JpD5lgKbZjX8CboPp
# eOICR0eK9BX5s+NawwT5YUCS68DelZJBzyg2GYXFd5VHJwUCAwEAAaN5MHcwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwYAYDVR0BBFkwV4AQjlf032OAQScHJycwJpr+8aEx
# MC8xLTArBgNVBAMTJGNvbVNjb3JlIFBvd2VyU2hlbGwgQ2VydGlmaWNhdGUgUm9v
# dIIQEnzWbQWFkYxLqR/4KpVPtTAJBgUrDgMCHQUAA4GBAAQ2E8fafy148Omr8tnM
# SbpoaCFHJCP3BnG0baTQQ4CuaX1z7Vm5K3NkytGEsLFo/TkxrDlOGYSPI/i/I60f
# KLlssiqvqacO+5YZfZhx3BSk7gSh8k+E5AYjX4Cj6w8ZrlxqbTn8Gx8QeTa2o4gq
# C4CgI19YpSSO5FqzkozDBeNaMYIBYzCCAV8CAQEwQzAvMS0wKwYDVQQDEyRjb21T
# Y29yZSBQb3dlclNoZWxsIENlcnRpZmljYXRlIFJvb3QCEDKkFWbTBK26R3mJWzQl
# GI4wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFDyZuxASFdoqs+CGTJeccLLpR9OCMA0GCSqGSIb3
# DQEBAQUABIGAQ5RzlpSdjBZTAh7uSqO/VwyKoxBsYQ72QuFp+m3nE84jcCQJFkwP
# uxzHIKIQOY3o/Vrou2ScbLF8SoBcHMFBxzlfq3m3o63ciwyPk6mbDAmFg2Z+krYc
# ZhfbyMpod97eo/YNVrN7u5V5sUFBdwlW5awIIlIw+bxgQAyv1fFGmgs=
# SIG # End signature block

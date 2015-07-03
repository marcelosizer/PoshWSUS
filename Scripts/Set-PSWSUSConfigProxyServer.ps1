function Set-PSWsusConfigProxyServer {
<#
.SYNOPSIS
	This cmdlet sets whether to use a proxy to download updates.
	
.PARAMETER UseProxy
    Sets whether to use a proxy to download updates. 
    $true to use a proxy to download updates, otherwise $false.
    To use a proxy you must specify the proxy server name and port number to use, as well as the user credentials if necessary.

.PARAMETER ProxyName
    The name of the proxy server to use to download updates. The name must be less than 256 characters. 
    You can specify a host name or an IP address. 
	
.PARAMETER ProxyServerPort
    The port number that is used to connect to the proxy server. The default is port 80. 
    The port number must be greater than zero and less than 65536. 

.PARAMETER ProxyCredential
    The user name and password to use when accessing the proxy server. The name must be less than 256 characters. 
	
.PARAMETER ProxyPassword
    Password to use when accessing the proxy.
        
.PARAMETER UseSeparateProxyForSsl
        Sets whether a separate proxy should be used for SSL communications with the upstream server.
        If $true, a separate proxy will be used when communicating with the upstream server.
        If $false, the same proxy will be used for both HTTP and HTTPS when communicating with the upstream server.

.PARAMETER SslProxyName
    The name of the proxy server for SSL communications.

.PARAMETER SslProxyServerPort
    The port number used to connect with the proxy server for SSL communications. 

.PARAMETER AnonymousProxyAccess
    Sets whether anonymous proxy server connections are allowed.
	$true to connect to the proxy server anonymously, $false to connect using user credentials.
    
.PARAMETER AllowProxyCredentialsOverNonSsl
	Sets whether user credentials can be sent to the proxy server using HTTP instead of HTTPS.
    If true, allows user credentials to be sent to the proxy server using HTTP; otherwise, the 
    user credentials are sent to the proxy server using HTTPS. 

    By default, WSUS uses HTTPS to access the proxy server. If HTTPS is not available and AllowProxyCredentialsOverNonSsl
    is $true, WSUS will use HTTP. Otherwise, WSUS will fail. Note that if WSUS uses HTTP to access the proxy server, the
    credentials are sent in plaintext.

.EXAMPLE
    Set-PSWsusConfigProxyServer -UseProxy $false

.EXAMPLE
    Set-PSWsusConfigProxyServer -UseProxy $true -ProxyName "proxy.domain.local" -ProxyServerPort "3128"

.EXAMPLE
    Set-PSWsusConfigProxyServer -UseProxy $true -SslProxyName "SslProxy.domain.local" -SslProxyServerPort 443

.EXAMPLE
    Set-PSWsusConfigProxyServer -UseProxy $true -ProxyName "proxy.domain.local" -ProxyServerPort "3128" `
    -AnonymousProxyAccess $true -AllowProxyCredentialsOverNonSsl $false

.EXAMPLE
    Set-PSWsusConfigProxyServer -UseProxy $true -ProxyName "proxy.domain.local" -ProxyServerPort "3128" `
    -AnonymousProxyAccess $false -ProxyCredential (Get-Credential) -ProxyUserDomain "domain" `
    -AllowProxyCredentialsOverNonSsl $true

.NOTES
	Name: Set-PSWsusConfigProxyServer
    Author: Dubinsky Evgeny
    DateCreated: 1DEC2013
    Modified 05 Feb 2014 - Boe Prox
        -Remove Begin, Process, End as function does not support pipeline input
        -Added -WhatIf support
        -Changed [boolean] param types to [switch] to align with best practices

.LINK
	http://blog.itstuff.in.ua/?p=62#Set-PSWSUSConfigProxyServer

#>

    [CmdletBinding(SupportsShouldProcess=$True)]
    Param
    (
        [switch]$UseProxy,
        [ValidateLength(1, 255)]
        [alias("SslProxyName")]
        [string]$ProxyName,
        [ValidateRange(0,65536)]
        [alias("SslProxyServerPort")]
        [int]$ProxyServerPort,
        [ValidateLength(1, 255)]
        [PSCredential]$ProxyCredential,
        [ValidateLength(1, 255)]
        [string]$ProxyUserDomain,
        # Gets or sets whether a separate proxy should be used for SSL communications with the upstream server. 
        [switch]$UseSeparateProxyForSsl,
        [switch]$AnonymousProxyAccess,
        [switch]$AllowProxyCredentialsOverNonSsl
    )

        if(-NOT $wsus)
        {
            Write-Warning "Use Connect-PSWSUSServer for establish connection with your Windows Update Server"
            Break
        }
        If ($PSCmdlet.ShouldProcess($wsus.ServerName,'Set Proxy Server')) {
            if ($PSBoundParameters['UseProxy'])
            {
                $config.UseProxy = $True
            }
            else
            {
                $config.UseProxy = $false
            }

            if ($PSBoundParameters['ProxyName'])
            {
                $config.ProxyName = $ProxyName
            }#endif
        
            if ($PSBoundParameters['ProxyServerPort'])
            {
                $config.ProxyServerPort = $ProxyServerPort
            }#endif
                
            if ($PSBoundParameters['ProxyCredential'] -ne $null)
            {
                $config.ProxyUserName = $ProxyCredential.GetNetworkCredential().UserName
            }#endif
            else
            {
                $config.ProxyUserName = $null
            }

            if ($PSBoundParameters['ProxyUserDomain'] -ne $null)
            {
                $config.ProxyUserDomain = $ProxyUserDomain
            }#endif
            else
            {
                $config.ProxyUserDomain = $null
            }         

            if ($PSBoundParameters['AnonymousProxyAccess'])
            {
                $config.AnonymousProxyAccess = $True
            }#endif
            else
            {
                $config.AnonymousProxyAccess  = $true
            }

            if ($PSBoundParameters['AllowProxyCredentialsOverNonSsl'])
            {
                $config.AllowProxyCredentialsOverNonSsl = $True
            }#endif
            else
            {
                $config.AllowProxyCredentialsOverNonSsl  = $false
            }
                
            if ($PSBoundParameters['UseSeparateProxyForSsl'])
            {
                $config.UseSeparateProxyForSsl = $True
            }#endif
            else
            {
                $config.UseSeparateProxyForSsl  = $false
            }

            $config.Save()
        }
}
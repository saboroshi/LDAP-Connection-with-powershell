<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2021 v5.8.196
	 Created on:   	2024. 03. 18. 08:45
	 Created by:   	Cservenyi Szabolcs
	 Organization: 	
	 Filename:     	LDAP-Connection.psm1
	 ReleaseNotes:	This module helps you connect to an MSSQL server and database.
	 Version:		1.0
	-------------------------------------------------------------------------
	 Module Name: 	LDAP-Connection
	===========================================================================
#>

function LDAP-Connection
{
	param (
		$ldapUser = "",
		$ldapPassword = "",
		$ldapServer = ""
	)
    
    Add-Type -Path 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.DirectoryServices.Protocols.dll'

	# We will create the authentication settings
	$ldapDirectoryIdentifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($ldapServer)
	
	# Let's try to connect to the LDAP server
	try
	{
		$ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapDirectoryIdentifier)
		$ldapConnection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic # For Microfocus Novell servers, the value of AuthType must be set to 'Basic'
		$ldapConnection.Bind()
		
		# Let's find the DN of the user
		$searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest("", "(cn=$ldapUser)", "sub", $null)
		$searchResponse = $ldapConnection.SendRequest($searchRequest) -as [System.DirectoryServices.Protocols.SearchResponse]
		$ldapUserDN = $searchResponse.Entries[0].DistinguishedName
		
		# Let's try to authenticate the user
		$ldapNetworkCredential = New-Object System.Net.NetworkCredential($ldapUserDN, $ldapPassword)
		$ldapConnection.Credential = $ldapNetworkCredential
		$ldapConnection.Bind()
		$true
	}
	catch
	{
		$false
	}
}

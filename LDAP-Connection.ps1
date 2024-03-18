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

	# Létrehozzuk a hitelesítési beállításokat
	$ldapDirectoryIdentifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($ldapServer)
	
	# Próbáljuk meg csatlakozni az LDAP szerverhez
	try
	{
		$ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapDirectoryIdentifier)
		$ldapConnection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic # Novell szerverek esetén az AuthType értékét 'Basic'-re kell állítani
		$ldapConnection.Bind()
		
		# Keressük meg a felhasználó DN-jét
		$searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest("", "(cn=$ldapUser)", "sub", $null)
		$searchResponse = $ldapConnection.SendRequest($searchRequest) -as [System.DirectoryServices.Protocols.SearchResponse]
		$ldapUserDN = $searchResponse.Entries[0].DistinguishedName
		
		# Próbáljuk meg hitelesíteni a felhasználót
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

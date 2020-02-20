Class GitHubRequester {
  $Domain = "api.github.com"
  $Headers = @{
    Accept = "application/vnd.github.v3+json"
  }
  $Credential = $Null

  GitHubRequester($Credential) {
    $this.Credential = $Credential
  }

  [object]Post($Endpoint, $Data) {
    return $this.Request('POST', $Endpoint, $Data)
  }

  [object]Get($Endpoint) {
    return $this.Request('GET', $Endpoint)
  }

  [object]Put($Endpoint, $Data) {
    return $this.Request('PUT', $Endpoint, $Data)
  }

  [object]Patch($Endpoint, $Data) {
    return $this.Request('PATCH', $Endpoint, $Data)
  }

  [object]Delete($Endpoint) {
    return $this.Request('DELETE', $Endpoint)
  }

  [object]Request($Method, $Endpoint) {
    return $this.Request($Method, $Endpoint, $null)
  }

  [object]Request($Method, $Endpoint, $Data) {
    $RestParams = @{
      Uri = "https://$($this.Domain)/$Endpoint"
      Method = $Method
      Headers = $this.Headers
      FollowRelLink = $true
      Authentication = 'Basic'
      Credential = $this.Credential
      ErrorAction = 'Stop'
    }

    if ($Data) {
      if (!($Data -is [String])) {
        $Data = $Data | ConvertTo-Json -Depth 10 -Compress
      }
      $RestParams.Body = $Data
      $RestParams.ContentType = 'application/json'
    }

    return $(Invoke-RestMethod @RestParams)
  }

}

Function New-GitHubRequester {
  Param(
    [Parameter(Mandatory)]
    [PSCredential] $Credential
  )

  New-Object GitHubRequester -ArgumentList $Credential
}

Export-ModuleMember -Function New-GitHubRequester

Class GitHubRequester
{
  $Domain = "api.github.com"
  $Headers = @{}

  GitHubRequester($username, $token)
  {
    $this.Headers = @{
      Authorization = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${token}")))"
      Accept = "application/vnd.github.v3+json"
    }
  }

  [object]Post($URL, $Data)
  {
    return $this.Request('POST', $URL, $Data)
  }

  [object]Get($URL)
  {
    return $this.Request('GET', $URL)
  }

  [object]Put($URL, $Data)
  {
    return $this.Request('PUT', $URL, $Data)
  }

  [object]Patch($URL, $Data)
  {
    return $this.Request('PATCH', $URL, $Data)
  }

  [object]Delete($URL)
  {
    return $this.Request('DELETE', $URL)
  }

  [object]Request($Method, $URL)
  {
    return $this.Request($Method, $URL, $null)
  }

  [object]Request($Method, $URL, $Data)
  {
    $URI = "https://$($this.Domain)/$URL"
    $Results = @()

    $RestParams = @{
      Method = $Method;
      Uri = $URI;
      Headers = $this.Headers;
    }

    if ($Data) {
      if (!($Data -is [String])) {
        $Data = $Data | ConvertTo-Json -Depth 10 -Compress
      }
      $RestParams.Body = $Data
      $RestParams.ContentType = 'application/json'
    }

    while (![string]::IsNullOrEmpty($RestParams.URI))
    {
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $ResponseHeaders = @{}
      $Results += $(Invoke-RestMethod @RestParams -ErrorAction Stop -ResponseHeadersVariable ResponseHeaders)
      $RestParams.URI = $Null
      if ($ResponseHeaders.Link) {
        ForEach ($link in $ResponseHeaders.Link.split(',')) {
          if ($link -match '<(?<next>[^>]*)>.*rel="next"\s*$') {
            $RestParams.URI = $Matches['next']
            break
          }
        }
      }
    }

    return $Results
  }

}

Function New-GitHubRequester {
  Param(
    [Parameter(Mandatory)]
    [String] $Username,
    [Parameter(Mandatory)]
    [String] $Token
  )

  New-Object GitHubRequester -ArgumentList $Email,$Token
}

Export-ModuleMember -Function New-GitHubRequester

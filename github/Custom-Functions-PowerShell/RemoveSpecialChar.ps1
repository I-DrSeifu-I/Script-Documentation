Function Remove-SpecialChar{
    [CmdletBinding()]
    param
    (
      [Parameter(ValueFromPipeline)]
      [ValidateNotNullOrEmpty()]
      [Alias('Text')]
      [System.String[]]$String,
      
      [Alias("Keep")]
      #[ValidateNotNullOrEmpty()]
      [String[]]$SpecialCharacterToKeep
    )
    PROCESS
    {
      IF ($PSBoundParameters["SpecialCharacterToKeep"])
      {
        $Regex = "[^\p{L}\p{Nd}"
        Foreach ($Character in $SpecialCharacterToKeep)
        {
          IF ($Character -eq "-"){
            $Regex +="-"
          } else {
            $Regex += [Regex]::Escape($Character)
          }
          #$Regex += "/$character"
        }
        
        $Regex += "]+"
      } #IF($PSBoundParameters["SpecialCharacterToKeep"])
      ELSE { $Regex = "[^a-zA-Z0-9]" }
      
      FOREACH ($Str in $string)
      {
        Write-Verbose -Message "Original String: $Str"
        $Str -replace $regex, ""
        #$Str -replace  ''
      }
    } #PROCESS
  }
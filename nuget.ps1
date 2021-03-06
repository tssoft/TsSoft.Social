del TsSoft.Social.*.nupkg
del *.nuspec
del .\TsSoft.Social\bin\Release\*.nuspec

function GetNodeValue([xml]$xml, [string]$xpath)
{
	return $xml.SelectSingleNode($xpath).'#text'
}

function SetNodeValue([xml]$xml, [string]$xpath, [string]$value)
{
	$node = $xml.SelectSingleNode($xpath)
	if ($node) {
		$node.'#text' = $value
	}
}

Remove-Item .\TsSoft.Social\bin -Recurse 
Remove-Item .\TsSoft.Social\obj -Recurse

$build = "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe ""TsSoft.Social\TsSoft.Social.csproj"" /p:Configuration=Release" 
Invoke-Expression $build

$Artifact = (resolve-path ".\TsSoft.Social\bin\Release\TsSoft.Social.dll").path

nuget spec -F -A $Artifact

Copy-Item .\TsSoft.Social.nuspec.xml .\TsSoft.Social\bin\Release\TsSoft.Social.nuspec

$GeneratedSpecification = (resolve-path ".\TsSoft.Social.nuspec").path
$TargetSpecification = (resolve-path ".\TsSoft.Social\bin\Release\TsSoft.Social.nuspec").path

[xml]$srcxml = Get-Content $GeneratedSpecification
[xml]$destxml = Get-Content $TargetSpecification
$value = GetNodeValue $srcxml "//version"
SetNodeValue $destxml "//version" $value;
$value = GetNodeValue $srcxml "//description"
SetNodeValue $destxml "//description" $value;
$value = GetNodeValue $srcxml "//copyright"
SetNodeValue $destxml "//copyright" $value;
$destxml.Save($TargetSpecification)

nuget pack $TargetSpecification

del *.nuspec
del .\TsSoft.Social\bin\Release\*.nuspec

exit

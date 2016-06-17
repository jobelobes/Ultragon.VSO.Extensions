[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $SourceFile,

    [String] [Parameter(Mandatory = $true)]
    $TransformFile,

    [String] [Parameter(Mandatory = $false)]
    $DestinationFile,
)

Write-Verbose "Entering script XmlTransformation.ps1"

try {
    if (!$SourceFile -or !(Test-Path -path $SourceFile -PathType Leaf)) {
        throw "File not found. $SourceFile";
    }
    if (!$TransformFile -or !(Test-Path -path $TransformFile -PathType Leaf)) {
        throw "File not found. $TransformFile";
    }

    if(!$DestinationFile){
        $DestinationFile = $SourceFile;
    }

    $scriptPath = (Get-Variable MyInvocation -Scope 1).Value.InvocationName | split-path -parent
    Add-Type -LiteralPath "$scriptPath\Microsoft.Web.XmlTransform.dll"

    $xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
    $xmldoc.PreserveWhitespace = $true
    $xmldoc.Load($SourceFile);

    $transf = New-Object Microsoft.Web.XmlTransform.XmlTransformation($TransformFile);
    if ($transf.Apply($xmldoc) -eq $false)
    {
        throw "Transformation failed."
    }
    $xmldoc.Save($SourceFile);    
} catch {
    Write-Error $_.Exception
    exit 1
}

Write-Verbose "Leaving script XmlTransformation.ps1"
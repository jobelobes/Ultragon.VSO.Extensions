[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $sourcePath,

    [String] [Parameter(Mandatory = $true)]
    $transformPath,

    [String] [Parameter(Mandatory = $false)]
    $targetPath
)

Write-Verbose "Entering script XmlTransformation.ps1"

try {
    if (!$sourcePath -or !(Test-Path -path $sourcePath -PathType Leaf)) {
        throw "File not found. $sourcePath";
    }
    if (!$transformPath -or !(Test-Path -path $transformPath -PathType Leaf)) {
        throw "File not found. $transformPath";
    }

    if(!$targetPath){
        $targetPath = $sourcePath;
    }

    $scriptPath = (Get-Variable MyInvocation -Scope 1).Value.InvocationName | split-path -parent
    Add-Type -LiteralPath "$scriptPath\Microsoft.Web.XmlTransform.dll"

    $xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
    $xmldoc.PreserveWhitespace = $true
    $xmldoc.Load($sourcePath);

    $transf = New-Object Microsoft.Web.XmlTransform.XmlTransformation($transformPath);
    if ($transf.Apply($xmldoc) -eq $false)
    {
        throw "Transformation failed."
    }
    $xmldoc.Save($sourcePath);    
} catch {
    Write-Error $_.Exception
    exit 1
}

Write-Verbose "Leaving script XmlTransformation.ps1"
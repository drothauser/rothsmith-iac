Import-Module AWSPowerShell
<#
    .SYNOPSIS
       Tests and creates a CloudFormation stack using Test-CFNStack & New-CFNStack using a template passed as a parameter
 
    .DESCRIPTION
        Using a template file on the local disk, calls Test-CFNTemplate to validate a single YAML or JSON CloudFormation template and, if valid, launches that stack into the current AWS account and region. Also shows elapsed stack creation time and stack creation status.
 
    .PARAMETER Template
        -Template [String]
 
    .EXAMPLE
        PS C:\> ./Create CloudFormation stack from-VPC-template.ps1 -Template .\MyCloudFormationTemplate.yaml
 
 
    .NOTES
        (c) 2017 Air11 Technology LLC -- licensed under the Apache OpenSource 2.0 license, https://opensource.org/licenses/Apache-2.0
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
 
        http://www.apache.org/licenses/LICENSE-2.0
 
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 
        Author's blog: https://www.yobyot.com
#>

param
(
    [parameter(Mandatory = $true)]
    [string]
    $Template
)
$templateBody = Get-Content -Path $Template -raw
Test-CFNTemplate -TemplateBody $templateBody
$AWSAPIResponse = (($AWSHistory.LastServiceResponse).GetType()).Name
$start = Get-Date
switch ($AWSAPIResponse)
{
    "ValidateTemplateResponse" {
        $timestamp = Get-Date -Format yyyy-MM-dd-HH-mm
        $stack = New-CFNStack -TemplateBody $templateBody `
                     -StackName "Stack-test-$timestamp" `
                     -DisableRollback $true `
                     -Parameter @(@{ Key = "VPCCIDR"; Value = "10.10.0.0/16"; UsePreviousValue = $false }; @{ Key = "PublicSubnetCIDR"; Value = "10.10.50.0/24"; UsePreviousValue = $false }; @{ Key = "PrivateSubnetCIDR"; Value = "10.10.60.0/24"; UsePreviousValue = $false }; @{ Key = "SSHLocation"; Value = "0.0.0.0/0"; UsePreviousValue = $false })
        do {
            Start-Sleep -Seconds 30
            $status = (Get-CFNStackSummary | Where-Object -Property StackID -EQ $stack).StackStatus
            "Stack status: $status Elapsed time: $( New-TimeSpan -Start $start -End (Get-Date) )" -f {g}
        } until ( ($status -eq "CREATE_COMPLETE") -or ($status -eq "CREATE_FAILED") )
    }
    default
    {
        "New-CFNStack failure: $AWSAPIResponse"
    }
}
"Last stack creation status $status"
"Total elapsed time: $( New-TimeSpan -Start $start -End (Get-Date) )" -f {g}
# Create the "Process Creation" Event Viewer сustom view to log the executed processes and their arguments
Function EnableEventViewerCustomView {
    Write-Output "Enabling Event Viewer Custom View ..."
    # Enable events auditing generated when a process is created (starts)
    auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable

    # Include command line in process creation events
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit -Name ProcessCreationIncludeCmdLine_Enabled -PropertyType DWord -Value 1 -Force
    #Set-Policy -Scope Computer -Path SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit -Name ProcessCreationIncludeCmdLine_Enabled -Type DWORD -Value 1

    $XML = @"
<ViewerConfig>
	<QueryConfig>
		<QueryParams>
			<UserQuery />
		</QueryParams>
		<QueryNode>
			<Name>$($Localization.EventViewerCustomViewName)</Name>
			<Description>$($Localization.EventViewerCustomViewDescription)</Description>
			<QueryList>
				<Query Id="0" Path="Security">
					<Select Path="Security">*[System[(EventID=4688)]]</Select>
				</Query>
			</QueryList>
		</QueryNode>
	</QueryConfig>
</ViewerConfig>
"@

    if (-not (Test-Path -Path "$env:ProgramData\Microsoft\Event Viewer\Views")) {
        New-Item -Path "$env:ProgramData\Microsoft\Event Viewer\Views" -ItemType Directory -Force
    }

    # Save ProcessCreation.xml in the UTF-8 with BOM encoding
    Set-Content -Path "$env:ProgramData\Microsoft\Event Viewer\Views\ProcessCreation.xml" -Value $XML -Encoding UTF8 -Force
}

# Remove the "Process Creation" Event Viewer custom view
Function DisableEventViewerCustomView {
    Write-Output "Disabling Event Viewer Custom View ..."
    Remove-Item -Path "$env:ProgramData\Microsoft\Event Viewer\Views\ProcessCreation.xml" -Force -ErrorAction Ignore
}
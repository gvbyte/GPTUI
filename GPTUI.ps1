[CmdletBinding()]
Param(
    [switch] $Menu,
    [switch] $Help,
    [switch] $Clear,
    [switch] $Report,
    [switch] $Log,
    [switch] $Load,
    [switch] $Patch,
    [switch] $Today,
    [string] $Server
)

class Modules {
    # Loads Log Class to begin logging
    static [void] LoadLog() {
        $LogModule = Join-Path -Path (Resolve-Path ".\etc\Modules\Log").Path -ChildPath "Log.psm1";
        Import-Module -Force $LogModule -Global;
        Trace-Info -module "Menu" -message "---> $($Env:USERNAME) INITIATED GPTUI <---";
        Trace-Info -module "Menu" -message "Loading module: Log";
    }

    static [void] LoadModule([string]$Module){
        Trace-Info -module "Menu" -message "Loading module: $($Module)";
        $Module = Join-Path -Path (Resolve-Path ".\etc\Modules\$($Module)").Path -ChildPath "$($Module).psm1"
        Import-Module $Module -Force;
    }
    
    static [void] LoadAD(){
        if(Get-Module -ListAvailable -Name ActiveDirectory){
            Trace-Info -module "Menu" -message "Importing module: ActiveDirectory";
            Import-Module -Name ActiveDirectory;
        }
        else {
            Trace-Warn -module "Menu" -message "[!] Failed to find module: Active Directory";
            Trace-Info -module "Menu" -message "[*] Attempting to install module: Active Directory";
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
                Add-WindowsCapability -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0' -Online;
                Trace-Success -module "Menu" -message "[!] Succesfully installed module: Active Directory";
            }
            catch {
                Trace-Error -module "Menu" -message "[!] Failed to install module: Active Directory";
            }
        }
    }

    static [void] LoadAll(){
        [Modules]::LoadLog();
        [Modules]::LoadModule('Menu');
        [Modules]::LoadModule('Email');
        [Modules]::LoadModule('Timer');
        [Modules]::LoadModule('WinOS');
        [Modules]::LoadAD();
    }

    static [void] LoadGPModules(){
        [Modules]::LoadLog();
        [Modules]::LoadModule('AD');
        [Modules]::LoadModule('XL');
        [Modules]::LoadModule('Email');
        [Modules]::LoadModule('Timer');
        [Modules]::LoadModule('WinOS');
        [Modules]::LoadAD();
    }

    static [void] LoadMenu(){[Modules]::LoadLog();[Modules]::LoadModule('Menu');}
    
}

switch ($true) {
    $Menu.IsPresent  {[Modules]::LoadAll();Show-Menu;}
    $Load.IsPresent  {[Modules]::LoadAll();}
    $Help.IsPresent  {[Modules]::LoadMenu();Show-Help;}
    $Clear.IsPresent {[Modules]::LoadMenu();Clear-Menu;}
    $Log.IsPresent   {[Modules]::LoadMenu();Show-Log;}
    $Patch.IsPresent {if($Today.IsPresent){[Modules]::LoadGPModules();Invoke-PatchToday}else{Show-Help}}
    Default          {[Modules]::LoadMenu();Show-Help;}
}
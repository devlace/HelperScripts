# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/change-availability-set

Login-AzureRmAccount

#set variables
$rg = "lalofran-sea-rg-03"
$vmName = "lalofranseavm02"
$newAvailSetName = "lalofranseaas01"
$outFile = "C:\temp\outfile.txt"

#Get VM Details
$OriginalVM = Get-AzureRmVM -ResourceGroupName $rg -Name $vmName

#Output VM details to file
"VM Name: " | Out-File -FilePath $outFile 
$OriginalVM.Name | Out-File -FilePath $outFile -Append

"Extensions: " | Out-File -FilePath $outFile -Append
$OriginalVM.Extensions | Out-File -FilePath $outFile -Append

"VMSize: " | Out-File -FilePath $outFile -Append
$OriginalVM.HardwareProfile.VmSize | Out-File -FilePath $outFile -Append

"NIC: " | Out-File -FilePath $outFile -Append
$OriginalVM.NetworkProfile.NetworkInterfaces[0].Id | Out-File -FilePath $outFile -Append

"OSType: " | Out-File -FilePath $outFile -Append
$OriginalVM.StorageProfile.OsDisk.OsType | Out-File -FilePath $outFile -Append

"OS Disk: " | Out-File -FilePath $outFile -Append
$OriginalVM.StorageProfile.OsDisk.Vhd.Uri | Out-File -FilePath $outFile -Append

if ($OriginalVM.StorageProfile.DataDisks) {
    "Data Disk(s): " | Out-File -FilePath $outFile -Append
    $OriginalVM.StorageProfile.DataDisks | Out-File -FilePath $outFile -Append
}

#Remove the original VM
Remove-AzureRmVM -ResourceGroupName $rg -Name $vmName

#Create new availability set if it does not exist
$availSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $newAvailSetName -ErrorAction Ignore
if (-Not $availSet) {
$availset = New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $newAvailSetName -Location $OriginalVM.Location
}

#Create the basic configuration for the replacement VM
$newVM = New-AzureRmVMConfig -VMName $OriginalVM.Name `
    -VMSize $OriginalVM.HardwareProfile.VmSize `
    -AvailabilitySetId $availSet.Id

# PICKONE
# 1. VHD
Set-AzureRmVMOSDisk -VM $NewVM `
    -VhdUri $OriginalVM.StorageProfile.OsDisk.Vhd.Uri  `
    -Name $OriginalVM.Name `
    -CreateOption Attach -Windows
# 2.
Set-AzureRmVMOSDisk `
    -VM $NewVM `
    -ManagedDiskId $OriginalVM.StorageProfile.OsDisk.ManagedDisk.Id `
    -CreateOption Attach -Windows


#Add Data Disks
foreach ($disk in $OriginalVM.StorageProfile.DataDisks ) { 
    Add-AzureRmVMDataDisk -VM $newVM `
        -Name $disk.Name `
        -VhdUri $disk.Vhd.Uri `
        -Caching $disk.Caching `
        -Lun $disk.Lun `
        -CreateOption Attach `
        -DiskSizeInGB $disk.DiskSizeGB
}

#Add NIC(s)
foreach ($nic in $OriginalVM.NetworkProfile.NetworkInterfaces) {
    Add-AzureRmVMNetworkInterface -VM $NewVM -Id $nic.Id
}

#Create the VM
New-AzureRmVM -ResourceGroupName $rg -Location $OriginalVM.Location -VM $NewVM -DisableBginfoExtension
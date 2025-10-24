
##############$ Set Permission #############

function set_new_permissions {

    param (
        [string]$resource,
        [int]$resource_id,
        [string]$group1,
        [string]$group2,
        [string]$group3,
        [string]$group4,
        [string]$group5
    )

    if ($resource -eq "flexible-assets") {
        $set_perm_url = "https://api.itglue.com/api/flexible_assets/$resource_id/relationships/resource_accesses"
    }
    else {
        $set_perm_url = "https://api.itglue.com/api/$resource/$resource_id/relationships/resource_accesses"
    }

    $groupIDs = @($group1, $group2, $group3, $group4, $group5) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    $data = @()
    foreach ($id in $groupIDs) {
        $data += @{
            type = "resource_accesses"
            attributes = @{
                accessor_id   = $id
                accessor_type = "Group"
            }
        }
    }

    # Convert to JSON body
    $bodyObject = @{ data = $data }
    $body = $bodyObject | ConvertTo-Json -Depth 5

    try {
        $set_security = Invoke-RestMethod -Uri $set_perm_url -Method 'PATCH' -Headers $headers -Body $body
        Write-Host "Permissions updated successfully for $resource_id" -ForegroundColor Green
    }
    catch {
        Write-Host "Error assigning groups to record ID $resource_id. Error: $($_.Exception.Message). Make sure groups have access to the organization assocuated to the asset!" -ForegroundColor Red
    }
}


############### Update Permission ##########

function update_permissions {

    param (
        [string]$resource,
        [string]$resource_id
    )
    if($resource -eq "flexible-assets"){
        $patch_URL = "https://api.itglue.com/api/flexible_assets/$resource_id"
    }
    else{
        $patch_URL = "https://api.itglue.com/api/$resource/$resource_id"
    }

$body = @"
{
    "data": {
        "type": "$resource",
        "attributes": {
            "restricted": true
        }
    }
}
"@


    try{

        $update = Invoke-RestMethod -Uri $patch_URL -Method 'PATCH' -Headers $headers -Body $body
        return $update
    }
    catch{

        Write-Host "Unable to update security for $resource_id . Error: $($_.exception.message)" -ForegroundColor Red
    
    }
    
    
}

################ Get group ID ##############

function get_group_id {

    param(
        [string]$name
    )

    $grp_filter_url = "https://api.itglue.com/groups?filter[name]=$name"
    
    try{
        $group = Invoke-RestMethod -Uri $grp_filter_url -Method 'GET' -Headers $headers

        return $($group.data.id)
    }
    catch{
        Write-Host "Unable to find the group with name $name. Please make sure the name is correct. Error: $($_.exception.message)" -ForegroundColor Red
    }

}

############### Fetcg info from CSV ########

function fetch_csv {

    $path = Read-Host "Please provide the CSV file path"
    $CSVData =  Import-Csv -Path $path

    foreach ($records in $CSVData){

        if(-not [string]::IsNullOrWhiteSpace($records.group1)){

            $grp1_id = get_group_id -name "$($records.group1)"
        
        }
        else{
            $grp1_id = "$($records.group1)"
        
        }
        if(-not [string]::IsNullOrWhiteSpace($records.group2)){

            $grp2_id = get_group_id -name "$($records.group2)"
        
        }
        else{
            $grp2_id = "$($records.group2)"
        
        }
        if(-not [string]::IsNullOrWhiteSpace($records.group3)){

            $grp3_id = get_group_id -name "$($records.group3)"
        
        }
        else{
            $grp3_id = "$($records.group3)"
        
        }
        if(-not [string]::IsNullOrWhiteSpace($records.group4)){

            $grp4_id = get_group_id -name "$($records.group4)"
        
        }
        else{
            $grp4_id = "$($records.group4)"
        
        }
        if(-not [string]::IsNullOrWhiteSpace($records.group5)){

            $grp5_id = get_group_id -name "$($records.group5)"
        
        }
        else{
            $grp5_id = "$($records.group5)"
        
        }
    
        $update_check = update_permissions -resource "$($records.resource_type)" -resource_id "$($records.resource_id)"

        if(-not [string]::IsNullOrWhiteSpace($update_check)){

            set_new_permissions -resource "$($records.resource_type)" -resource_id "$($records.resource_id)" -group1 "$grp1_id" -group2 "$grp2_id" -group3 "$grp3_id" -group4 "$grp4_id" -group5 "$grp5_id"
        }
        else{ 
            Write-Host "Could not update the permission for resource with ID: $($records.resource_id)" -ForegroundColor Red
        
        }
    
    }


}

############# Headers ######################

function set_headers {
    
    param (
        [string]$API
    )

    $global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $global:headers.Add("x-api-key", "$API")
    $global:headers.Add("Content-Type", "application/json")
}
############## Request data #################

function request_data {
    if($api_key -eq $null) {
        
        $api_key = Read-Host "Please provide your IT Glue API key"

        set_headers -API "$api_key"

    }
    else{
        Write-Host "Using the existing API key: $api_key"
    }

    fetch_csv
}
################ Main execution ####################

request_data

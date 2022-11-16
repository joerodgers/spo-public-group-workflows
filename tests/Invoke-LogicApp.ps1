
# test group object id, just exist in the tenant
$groupId = "ff571c86-3414-4378-9448-0037d5df9c48" 

# url of your logic app
$logicAppUri = 'https://prod-61.eastus.logic.azure.com:443/workflows/<........>' 

# request body
$body = "{ `"groupId`": `"$groupId`"  }"

# simulate spo site creation webhook post request
Invoke-RestMethod -Method Post -Uri $logicAppUri -Body $body -ContentType "application/json"

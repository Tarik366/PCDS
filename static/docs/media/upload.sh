 #Client area
 token="2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
 secret_key="123456"
 apiEndpoint="http://cds.plexusteam.org/api/$token"
 force='false'
 subDir="/"
 #Client area


# Check connection with the server
ping -c 1 cds.plexusteam.org > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "Failed to connect to the server."
    exit 1
fi

 # Check if the file exists
 # Parse command line arguments
 while [[ $# -gt 0 ]]; do
     key="$1"

     case $key in
         --force)
             force="$2"
             shift
             ;;
         --file)
             file="$2"
             shift
             ;;
        --sub)
             subDir="$2"
             shift
             ;;
         *)
             # Unknown option
             echo "Unknown option: $1"
             exit 1
             ;;
     esac
     shift
 done

 # Use the value of the --force parameter
 if [[ "$force" =~ ("True"|"true") ]]; then
     force="true"
 else
     force="false"
 fi

 [[ -f "$file" ]] || { echo -e "404 File Not Found"; exit 1; }


 # Create a temporary JSON file with the required data
json_data=$(cat <<EOF
{
"secret_key": "$secret_key",
"procClass": "upload",
"subDir": "$subDir",
"force": $force
}
EOF
)
temp_json_file=$(mktemp)
echo "$json_data" > "$temp_json_file"

 # Send the file with the temporary JSON file
curl -X POST -H "Content-Type: multipart/form-data" -F "file=@$file" -F "json_data=@$temp_json_file" $apiEndpoint

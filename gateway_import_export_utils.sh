#!/bin/bash
##############################################################################
##
#download#
##
##############################################################################
CURR_DIR="$PWD"
url=http://localhost:5555
username=Administrator
password=manage
api=
shldDoImport=
#Usage of this script
usage(){
echo "Usage: $0a rgs"
echo "args:"
echo "--import(or)--export  *To import or export from the flat file"
echo "--api.name		    *The API project to import"
echo "--apigateway.url      APIGateway url to import or export from.Default is http://localhost:5555"
echo "--username            The APIGateway username.Default is Administrator."
echo "--password            The APIGateway password.Default is password."
exit
}

#Parseinputarguments
parseArgs(){
  while test $# -ge 1; do
    arg=$1
    shift
    case $arg in
      --apigateway.url)
        url=${1}
        shift
      ;;
      --api.name)
        api=${1}
        shift
      ;;
      --username)
        username=${1}
        shift
      ;;      
      --password)
        password=${1}
        shift
	  ;;	
	  --import)
        shldDoImport='true'
      ;;
	  --export)
        shldDoImport='false'
      ;;
	  -h|--help)
        usage
	  ;;
	  *)
        echo "Unknown: $@"
        usage
		exit
      ;;
    esac
  done
}

main(){
#Parseinputarguments
parseArgs "$@"
if [ -z "$api" ] 
then 
echo "API name is missing" 
usage
fi
if [ -z "$shldDoImport" ] 
then 
echo "Missing what operation to do" 
usage
fi

if [ "$shldDoImport" = "true" ]
then
    echo "Importing the API"
	if [ -d "$CURR_DIR/apis/$api" ] 
	then
	cd $CURR_DIR/apis/$api/ && zip -r $CURR_DIR/$api.zip ./*
	curl -i -X POST $url/rest/apigateway/archive?overwrite=* -H "Content-Type:application/zip" -H"Accept:application/json" --data-binary @"$CURR_DIR/$api.zip" -u $username:$password
	rm $CURR_DIR/$api.zip
	else
	echo "The API with name $api does not exists in the flat file."
	fi
else
	if [ -d "$CURR_DIR/apis/$api" ] 
	then
	curl $url/rest/apigateway/archive -d @"$CURR_DIR/apis/$api/export_payload.json" --output $CURR_DIR/$api.zip -u $username:$password -H "x-HTTP-Method-Override:GET" -H "Content-Type:application/json"
	unzip -o $CURR_DIR/$api.zip -d $CURR_DIR/apis/$api/
	rm $CURR_DIR/$api.zip
	else
	echo "The API with name $api does not exists in the flat file."
	fi
fi
}


#Call the main function with all arguments passed in...
main "$@"
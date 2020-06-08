#!/bin/bash
##############################################################################
##
#download#
##
##############################################################################
. ./common.lib
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
	import_api $api $url $username $password
else
	export_api $api $url $username $password
fi
}


#Call the main function with all arguments passed in...
main "$@"
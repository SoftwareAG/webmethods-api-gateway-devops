#!/bin/bash
##############################################################################
##
#download#
##
##############################################################################

CURR_DIR="$PWD"
. ./common.lib
apigateway_image=
apigateway_server_port=5555
apigateway_ui_port=9072
create_new=false
apigateway_es_port=9240
test_suite=
#Usage of this script
usage(){
echo "Usage: $0"
echo "args:"
echo "--apigateway_image(*)	    The DTR for API Gateway image."
echo "--apigateway_server_port  API Gateway server port.Default is 5555"
echo "--apigateway_ui_port      API Gateway UI port.Default is 9072"
echo "--apigateway_es_port		API Gateway Elastic search port.Default is 9240"
echo "--create_new              Create new API Gateway container even if an existing container is running by killing it.Default is false."
echo "--test_suite              The postman collection test_suite to run.Default will not run any test.To run all tests pass *"
exit
}

#Parseinputarguments
parseArgs(){
  while test $# -ge 1; do
    arg=$1
    shift
    case $arg in
	  --apigateway_image)
        apigateway_image=${1}
        shift
	  ;;
	  --apigateway_server_port)
        apigateway_server_port=${1}
        shift
	  ;;
	  --apigateway_ui_port)
        apigateway_ui_port=${1}
        shift
	  ;;
	  --apigateway_es_port)
        apigateway_es_port=${1}
        shift
	  ;;
	  --create_new)
	    create_new=${1}
		shift
	  ;;	
	  --test_suite)
	    test_suite=${1}
		shift
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
if [ -z "$apigateway_image" ] 
then 
echo "apigateway_image name is missing." 
usage
fi

echo "Start the environment"
sh gateway_setup.sh  --stage dev --apigateway_image $apigateway_image --apigateway_server_port $apigateway_server_port --apigateway_ui_port $apigateway_ui_port --apigateway_es_port $apigateway_es_port --create_new $create_new


echo "Checking the API Gateway is up" 
ping_apigateway_server http://localhost:$apigateway_server_port 30 30
PING_RETURN_CODE=$?
if [ $PING_RETURN_CODE -eq 0 ]
then
echo "API Gateway at http://localhost:$apigateway_server_port is not up.Exiting"
exit
fi

echo "Importing all the APIs to the Build machine"
for file in ../apis/*; do
    if [ -d "$file" ]; then
        import_api $file http://localhost:$apigateway_server_port "Administrator" "manage"
    fi
done

if [ ! -z "$test_suite" ] 
then
echo "Not running the tests"
exit
fi

echo "Running tests for API gateway"
if [ $test_suite -eq * ] 
then 
for file in ../tests/test-suites/*; do
    if [ -d "$file" ]; then
        run_test $file ../tests/environment/build_environment.json
    fi
done
exit
fi

run_test $test_suite ../tests/environment/build_environment.json


cd $PWD
}


#Call the main function with all arguments passed in...
main "$@"
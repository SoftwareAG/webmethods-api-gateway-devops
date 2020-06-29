#!/bin/bash
##############################################################################
##
##
##
##############################################################################
CURR_DIR="$PWD"
. ./common.lib
stage=
apigateway_image=
terracotta_image=
apigateway_server_port=5555
apigateway_ui_port=9072
apigateway_es_port=9240
create_new=false
import_configurations=true
cleanup=false
#Usage of this script
usage(){
echo "Usage: $0"
echo "args:"
echo "--stage(*)                   Possible value are dev,qa,prod"
echo "--apigateway_image	       The DTR for API Gateway image"
echo "--terracotta_image           The DTR for Terracotta image in case of cluster environments"
echo "--apigateway_server_port     API Gateway server port"
echo "--apigateway_ui_port         API Gateway UI port"
echo "--apigateway_es_port		   API Gateway Elastic search port"
echo "--create_new                 Create new even if an existing container is running by killing it"
echo "--import_configurations      Import configurations into the created container"
echo "--cleanup     			   Cleanup the created images"
exit
}

#Parseinputarguments
parseArgs(){
  while test $# -ge 1; do
    arg=$1
    shift
    case $arg in
      --stage)
        stage=${1}
        shift
	  ;;
	  --apigateway_image)
        apigateway_image=${1}
        shift
	  ;;
	  --terracotta_image)
        terracotta_image=${1}
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
	  --import_configurations)
	    import_configurations=${1}
		shift
	  ;;
	  --cleanup)
	    cleanup=true
	  ;;
	  *)
        echo "Unknown: $arg"
        usage
		exit
      ;;
    esac
  done
}

main(){
#Parseinputarguments
parseArgs "$@"
if [ -z "$stage" ] 
then 
	echo "Stage name is missing." 
	usage
fi

if [ $cleanup = "true" ] 
then
	cd ../deployment-descriptors/$stage
	docker-compose rm -f -s -v
	cd $CURR_DIR
	exit
fi


if [ $stage = "dev" ] 
then
 echo ""
elif [ $stage = "build" ]
then
 echo ""
else 
	if [ -z "$terracotta_image"]
	then
	echo "Terracotta image name is missing."
	usage
fi
fi


echo "Staring an API Gateway environment for $stage"
cd ../deployment-descriptors/$stage
cat > .env <<EOF
apigateway_image=$apigateway_image
apigateway_server_port=$apigateway_server_port
apigateway_ui_port=$apigateway_ui_port
apigateway_es_port=$apigateway_es_port
EOF

if [ -z "$terracotta_image" ] 
then 
echo ""
else 
cat >> .env <<EOF
terracotta_image=$terracotta_image
EOF
fi

if [ $create_new = "true" ] 
then
docker-compose kill 
sleep 30
fi

docker-compose up -d

echo "Checking the API Gateway is up" 
ping_apigateway_server http://localhost:$apigateway_server_port 30 30
PING_RETURN_CODE=$?
if [ $PING_RETURN_CODE -eq 0 ]
then
echo "API Gateway at http://localhost:$apigateway_server_port is not up.Exiting"
exit
fi

echo "API Gateway is up"
if [ $import_configurations = "true" ] 
then
 echo "Importing Configuration into the Environment"
if [ $stage = "build" ] 
then
 conf_stage=dev
else 
 conf_stage=$stage
fi

cd $CURR_DIR

for file in ../configuration/$conf_stage/*; do
    echo "$file"
    import_configurations $file http://localhost:$apigateway_server_port "Administrator" "manage" $conf_stage
done
fi


}


#Call the main function with all arguments passed in...
main "$@"
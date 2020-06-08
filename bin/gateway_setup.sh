#!/bin/bash
##############################################################################
##
#download#
##
##############################################################################
CURR_DIR="$PWD"
stage=
apigateway_image=
terracotta_image=
apigateway_server_port=5555
apigateway_ui_port=9072
apigateway_es_port=9240
create_new=false
#Usage of this script
usage(){
echo "Usage: $0"
echo "args:"
echo "--stage                   Start API Gateway docker instance in what stage? Possible value are dev,qa,prod"
echo "--apigateway_image	    The DTR for API Gateway image"
echo "--terracotta_image        The DTR for Terracotta image"
echo "--apigateway_server_port  API Gateway server port"
echo "--apigateway_ui_port      API Gateway UI port"
echo "--apigateway_es_port		API Gateway Elastic search port"
echo "--create_new              Create new even if an existing container is running by killing it.Default is false."
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
if [ -z "$stage" ] 
then 
echo "Stage name is missing." 
usage
fi
if [ -z "$apigateway_image" ] 
then 
echo "apigateway_image name is missing." 
usage
fi




echo "Staring an API Gateway environment for $stage"
echo "APIGateway image is present at $apigateway_image"
cd ../deployment-descriptors/$stage
cat > .env <<EOF
apigateway_image=$apigateway_image
apigateway_server_port=$apigateway_server_port
apigateway_ui_port=$apigateway_ui_port
apigateway_es_port=$apigateway_es_port
EOF

if [ ! -z "$terracotta_image" ] 
then 
cat >> .env <<EOF
terracotta_image=$terracotta_image
EOF
fi

if [ $create_new -eq true ] 
then
docker-compose kill 
sleep 30
fi

docker-compose up -d

cd $PWD
}


#Call the main function with all arguments passed in...
main "$@"
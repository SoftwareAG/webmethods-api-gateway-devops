# webmethods-api-gateway-devops
This is a sample repository that a organization can have for its CI/CD for
API Gateway assets.


The repository has the following folders
  - apis : Contains the API Gateway assets of the organization 
  - configuration : Contains staged specfic API Gateway Administration configurations.
  - deployment-descriptor : Contains staged specific docker compose files to create API Gateway environments.
  - tests : Contains the Postman Test suites and Environmental variables required for the test suites.
  - utilities : Contains the Postman collections for Import/Export, Promotion management.
  - bin : Library scripts that are used to create API Gateway environments, Develop assets and test them.
  - pipelines : Contains some sample Jenkins and the Azure pipelines as an insight for organizations. 
  
# Create an API Gateway environment
The gateway-setup.sh can be used to create stage specific API Gateway environment. 
The Docker compose files are present at deployment-descriptors.
Dev and Build stages are single node instances and QA and Prod are
3 node clusters.
# Parameters
| Parameter | Description |
| ------ | ------ |
| stage |  Possible value are build,dev,qa,prod. |
| apigateway_image | The DTR for API Gateway image. |
| terracotta_image | The DTR for Terracotta image in case of cluster environments |
| apigateway_server_port | API Gateway server port.Default is 5555 |
| apigateway_ui_port | API Gateway UI port.Default is 9072 |
| apigateway_es_port |  API Gateway Elastic search port.Default is 9240 |
| create_new | Create new API Gateway container even if an  existing container is running by killing it.Default is false | 
| import_configurations | Import configurations into the created container|
| cleanup | Cleanup the created images |

Sample usage to create a prod environment
```sh
 $ gateway-setup.sh --stage prod  --apigateway_image mycompany_apigateway_image:latest --terracotta_image mycompany_terracotta_image:latest --create_new true 
```
To clean up the created environment
```sh
 $ gateway_setup.sh --stage dev --cleanup
```
# Develop APIs and test
The gateway_import_export_utils.sh can be used for developers import and export APIs(projects)  as a flat file representation of the VCS.

# Parameters
| Parameter | README |
| ------ | ------ |
| import(or)export |  To import or export from the flat file. |
| api_name | The API project to import.|
| apigateway_url |  APIGateway url to import or export from.Default is http://localhost:5555.|
| apigateway_es_port | API Gateway Elastic search port.Default is 9240|
| username |  The APIGateway username.Default is Administrator.|
| password | The APIGateway password.Default is password.|

Sample Usage for importing the API petstore that is present as flat file under apis/petstore into API Gateway server at http://localhost:5555 

```sh
 $ gateway_import_export_utils.sh  --import --api_name petstore --apigateway_url http://localhost:5556
```
Sample Usage for exporting the API petstore that is present in the  API Gateway server at http://localhost:5555  as flat file under apis/petstore

```sh
 $ gateway_import_export_utils.sh  --export --api_name petstore --apigateway_url http://localhost:5556
```

There is also a build script gateway_build.sh that can be used for developers to validate the changes made to the APIs. This creates an single node Docker based API Gateway environment 
imports the entire set and of API Projects and then run the tests suites 
against the build machine.

# Parameters
| Parameter | Description |
| ------ | ------ |
| apigateway_image | The DTR for API Gateway image. |
| apigateway_server_port | API Gateway server port.Default is 5555 |
| apigateway_ui_port | API Gateway UI port.Default is 9072 |
| apigateway_es_port |  API Gateway Elastic search port.Default is 9240 |
| create_new | Create new API Gateway container even if an  existing container is running by killing it.Default is false | 
| test_suite |  The postman collection test_suite to run. Default will not run any test.To run all tests pass *|
| skip_import | To skip the import of APIs |

Sample usage to run all tests by creating an build environment
``` sh 
gateway_build.sh --apigateway_image mycompany_apigateway_image:latest --apigateway_server_port 5558 --apigateway_ui_port 9075  --apigateway_es_port 9243 --test_suite \*
```

Sample usage to run only a subset of tests
``` sh 
gateway_build.sh --apigateway_server_port 5558 --test_suite ../tests/test-suites/APITest.json
```

# Pipelines
This repository contains a sample Jenkins and Azure pipline that can be used for the Continious integration process.
These pipelines depicts how an API(project) that is present in VCS can be promoted to an API Gateway Prod environment  after testing it in the  API Gateway QA environment. The API(project) is imported in the QA environment and after running tests it is promoted to the Prod using the Promotion mangement APIs.  



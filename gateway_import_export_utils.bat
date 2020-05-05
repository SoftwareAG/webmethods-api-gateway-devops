@echo OFF

set CURRENT_DIR=%~dp0

if "%2" == "-api_name" (
set PROJECT_NAME=%3
) ELSE (
  echo "Please specify an API name"
  goto :EOF
)

if "%4" == "-apigateway_url" (
set GATEWAY_URL=%5
) ELSE (
  echo "Please specify the gateway url"
  goto :EOF
)

IF "%1" == "import" (
goto import
) ELSE (
 goto export
)

:import 
IF EXIST %CURRENT_DIR%/apis/%PROJECT_NAME%/ (
 powershell Compress-Archive -Path %CURRENT_DIR%/apis/%PROJECT_NAME%/* -DestinationPath %CURRENT_DIR%/%PROJECT_NAME%.zip -Force
 curl -i -X POST %GATEWAY_URL%/rest/apigateway/archive?overwrite=* -H "Content-Type: application/zip" -H "Accept:application/json" --data-binary @"%CURRENT_DIR%/%PROJECT_NAME%.zip" --user Administrator:manage
 del "%CURRENT_DIR%/%PROJECT_NAME%.zip"
 goto :EOF
) ELSE (
  echo "API with name %PROJECT_NAME% does not exists"
  goto :EOF
)

:export
IF EXIST %CURRENT_DIR%/apis/%PROJECT_NAME%/ (
 curl %GATEWAY_URL%/rest/apigateway/archive -d @"%CURRENT_DIR%\apis\%PROJECT_NAME%\export_payload.json" --output %CURRENT_DIR%/%PROJECT_NAME%.zip -u  Administrator:manage -H "x-HTTP-Method-Override: GET" -H "Content-Type:application/json"
 powershell Expand-Archive -Path %CURRENT_DIR%/%PROJECT_NAME%.zip -DestinationPath %CURRENT_DIR%/apis/%PROJECT_NAME% -Force
 del "%CURRENT_DIR%/%PROJECT_NAME%.zip"
goto :EOF
) ELSE (
  echo "API with name %PROJECT_NAME% does not exists"
  goto :EOF
)



 





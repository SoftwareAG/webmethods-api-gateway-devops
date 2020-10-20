@echo OFF

set CURRENT_DIR=%~dp0

set ACTION=%1
SHIFT 

:loop
IF NOT "%1"=="" (
    IF "%1"=="_api_name" (
        SET PROJECT_NAME=%3
        SHIFT
    )
    IF "%1"=="-apigateway_url" (
        SET GATEWAY_URL=%2
        SHIFT
    )
	IF "%1"=="-apigateway_username" (
        SET GATEWAY_USERNAME=%2
        SHIFT
    )
	IF "%1"=="-apigateway_password" (
        SET GATEWAY_PASSWORD=%2
        SHIFT
    )
    SHIFT
    GOTO :loop
)

IF "%ACTION%" == "import" (
goto import
) ELSE (
 goto export
)

:import 
IF EXIST %CURRENT_DIR%/apis/%PROJECT_NAME%/ (
 powershell Compress-Archive -Path %CURRENT_DIR%/apis/%PROJECT_NAME%/* -DestinationPath %CURRENT_DIR%/%PROJECT_NAME%.zip -Force
 curl -i -X POST %GATEWAY_URL%/rest/apigateway/archive?overwrite=* -H "Content-Type: application/zip" -H "Accept:application/json" --data-binary @"%CURRENT_DIR%/%PROJECT_NAME%.zip" --user %GATEWAY_USERNAME%:%GATEWAY_PASSWORD%
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



 





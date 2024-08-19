REM FROM: https://github.com/pfirsich/makelove/

REM Imprescindible Python 3.7 (pip)
REM pip3 install makelove

REM Para generar un archivo de configuración 'makelove.toml'
REM makelove --init

REM o sin configuración
REM makelove

REM o con versiones 
REM makelove --version-name 0.1

REM o ayuda
REM makelove --help

REM la opción --resume solo realiza cambios si son necesarios

REM compilación : crea el directorio de compilación y los ejecutables
makelove --config make_all.toml
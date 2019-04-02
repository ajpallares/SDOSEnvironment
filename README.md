- [SDOSEnvironment](#sdosenvironment)
  - [Introducción](#introducci%C3%B3n)
  - [Instalación](#instalaci%C3%B3n)
    - [Cocoapods](#cocoapods)
  - [Cómo se usa](#c%C3%B3mo-se-usa)
    - [Script de encriptación y generación de código](#script-de-encriptaci%C3%B3n-y-generaci%C3%B3n-de-c%C3%B3digo)
      - [Qué hace el script](#qu%C3%A9-hace-el-script)
      - [Anotaciones](#anotaciones)
    - [Implementación](#implementaci%C3%B3n)
  - [Dependencias](#dependencias)
  - [Referencias](#referencias)

# SDOSEnvironment

- Enlace confluence: https://kc.sdos.es/x/PwLLAQ
- Documentación: https://svrgitpub.sdos.es/iOS/SDOSEnvironment/tree/master/docs/docs/index.html

## Introducción
SDOSEnvironment es una librería que permite configurar constantes que tengan valores diferentes para cada **entorno de ejecución** (*Debug, Preproduction, Production, etc*). Esto es muy útil para casos como **url de ws**, **claves de analíticas**, etc, donde en cada entorno de ejecución pueden ser diferentes. Con está librería cada entorno dispondrá de los valores correctos, sin necesidad de modificarlos dependiendo del que queramos ejecutar.
Además, la librería aporta un punto extra de seguridad encriptando el fichero que contiene las variables de entorno, haciendo más dificil para un atacante ver los valores que contiene.

## Instalación

### Cocoapods

Usaremos [CocoaPods](https://cocoapods.org). Hay que añadir la dependencia al `Podfile`:

```ruby
pod 'SDOSEnvironment', '~>1.0.0' 
```

## Cómo se usa

La librería proporciona todo lo necesario para usar las variables de entorno, sin que el usuario tenga que escribir ninguna función ya que contiene un `script` para encriptar el fichero de xml con la configuración de los entornos y generar el código necesario para acceder a estos valores.

### Script de encriptación y generación de código

El *script de encriptación y generación de código* no se incluye en el binario de la aplicación. Hay que hacer uso de él durante las `Build Phases`. Para ello hay que seguir los siguientes pasos:
1. Añadir el fichero Environments.plist con las variables y los entornos. Este fichero no se debe incluir al target ya que no debe ir en el binario de la aplicación. Copiar el siguiente código para crear un fichero básico:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>wsUrl</key>
	<dict/>
	<key>Debug</key>
	<string>https://debug.com</string>
	<key>Preproduction</key>
	<string>https://preproduction.com</string>
	<key>Production</key>
	<string>https://production.com</string>
</dict>
</plist>
```
2. En Xcode: Seleccionar el proyecto, elegir el TARGET, selccionar la pestaña de `Build Phases` y pulsar en añadir `New Run Script Phase` en el icono de **+** arriba a la izquierda
3. Arrastrar el nuevo `Run Script` justo antes de `Compile Sources`
4. (Opcional) Renombrar el script a `SDOSEnvironment - Encrypt environments`
5. Copiar el siguiente script:
    ```sh
    "${PODS_ROOT}/SDOSEnvironment/src/Scripts/SDOSEnvironment" -b ${PRODUCT_BUNDLE_IDENTIFIER} -i "${SRCROOT}/main/resources/Environments.plist" -output-bin "${SRCROOT}/main/resources/generated/Environments.bin" -output-file "${SRCROOT}/main/resources/generated/EnvironmentGenerated.swift" -validate-environment ${SDOSEnvironment}
    ```
    <sup><sub>Los valores del script pueden cambiarse en función de las necesidades del proyecto</sup></sub>
6. Añadir `${SRCROOT}/main/resources/Environments.plist` al apartado `Input Files`. **No poner comillas**
7. Añadir `${SRCROOT}/main/resources/generated/Environments.bin` al apartado `Output Files`. **No poner comillas**
8. Añadir `${SRCROOT}/main/resources/generated/EnvironmentGenerated.swift` al apartado `Output Files`. **No poner comillas**
9.  Compilar el proyecto. Esto generará los ficheros en la ruta `${SRCROOT}/main/resources/generated/` que deberán ser incluidos en el proyecto

#### Qué hace el script
En cada compilación, si se ha modificado el fichero `${SRCROOT}/main/resources/Environments.plist` el `Build Phase` se volverá a ejecutar realizando la siguientes labores:
* Validar el fichero indicado en el parámetro `-i` y encriptarlo en base al parámetro `-b`. El script usa está información para generar una contraseña de encriptación. **IMPORTANTE**: este valor debe ser el mismo al realizar la configuración en el código. En caso contrario la librería no podrá desencriptar el fichero
* Generar el fichero con las variables encriptadas en la ruta `-output-bin`
* Generar el fichero con el código swift en la ruta `-output-file`
* Validar si todas las variables tienen el entorno indicado en el parámetro `-validate-environment`

El script tiene los siguientes parámetros que pueden incluirse en base a las necesidades del proyecto:

|Parámetro|Descripción|Ejemplo|
|---------|-----------|-------|
|`-i [valor]`|Ruta del fichero de entrada. Debe ser un .plist|`${SRCROOT}/main/resources/Environments.plist`|
|`-output-bin [valor]`|Ruta del fichero encriptado de salida. Debe incluir el nombre del fichero a generar|`${SRCROOT}/main/resources/generated/Environments.bin`|
|`-b [valor]`|Bundle identifier de la aplicación. Se usará para generar la contraseña del fichero encriptado en base a éste|`${PRODUCT_BUNDLE_IDENTIFIER}` // `es.sdos.bundleid`|
|`-output-file [valor]`|Ruta del fichero autogenerado de salida. Debe incluir el nombre del fichero a generar|`${SRCROOT}/main/resources/generated/EnvironmentGenerated.swift`|
|`-validate-environment [valor]`|String correspondiente al entorno que se quiere validar. La validación comprobará que todas las claves indicadas en el fichero tengan un valor para el entorno definido|`${SDOSEnvironment}` // `Debug`|
|`-p [valor]`|Contraseña usada para encriptar el fichero. Éste paraámetro no tendrá en cuenta si se ha indicado el parámetro `-b`|`Aa123456`|
|`--disable-input-output-files-validation`|Deshabilita la validación de los inputs y outputs files. Usar sólo para dar compatibilidad a `Legacy Build System`|
|`--unlock-files`|Indica que los ficheros de salida no se deben bloquear en el sistema|

<sup><sub>Puedes consultar la ayuda completa ejecutando `./SDOSEnvironment help` en el terminal</sup></sub>

#### Anotaciones
El formato del fichero Environments.plist es el siguiente: 
* En la raiz del xml se crean variables de tipo `Dictionary` que serán las claves de las variables de entorno
* Dentro de cada `Dictionary` se crean variables de tipo `Strings` donde cada clave es el entorno y el valor será el que se recupere cuando se solicite 


### Implementación

Para usar la librería sólo es necesario lanzar la configuración inicial de la librería y usar el código swift que genera el script. Se recomienda añadir como primera línea de ejecución de la aplicación la configuración de la librería:
1. Añadir el valor `SDOSEnvironment` al `Build Setting` como `User Define` o en los ficheros `.xcconfig` de cada entorno, con su valor correspondiente (*Debug*, *Preproduction* o *Production*)
2. Añadir el siguiente código al `Info.plist` del proyecto
    ```xml
    <key>EnvironmentKey</key><string>$(SDOSEnvironment)</string>
    ```
    **Si la variable `SDOSEnvironment` cambia habrá que hacer un Clean del proyecto para que se vea reflejada**


3. Lanzar la configuración de la librería:
    ```js
    SDOSEnvironment.configure(activeLogging: true)
    ```
4. Usar el código autogenerado donde se requiera
    ```js
    Environment.wsUrl
    ```

## Dependencias
* [RNCryptor](https://github.com/RNCryptor/RNCryptor) - 5.x

## Referencias
* https://svrgitpub.sdos.es/iOS/SDOSEnvironment
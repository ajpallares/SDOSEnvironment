## [0.9.4 Añadido soporte para el nuevo Build System](https://svrgitpub.sdos.es/iOS/SDOSEnvironment/tree/v0.9.4)

- Se ha añadido soporte para el nuevo Build System. Ahora es necesario poner las rutas correctas en los campos input files y output files
- Se han añadido nuevos parámetros para dar soporte al Legacy Build System. El parámetro --disable-input-output-files-validation elimina la validación de los input files y output files
- Por defecto los ficheros generados se bloquean en el sistema. Si se quiere que no se bloqueen se debe poner el parámetro --unlock-files
- Cambiado nombre del parámetro -validate por -validate-environment

## [0.9.3 Añadido parámetro para recuperar el entorno del info.plist](https://svrgitpub.sdos.es/iOS/SDOSEnvironment/tree/v0.9.3)

- Se ha añadido la funcionalidad de recuperar el entorno a partir de la clave *EnvironmentKey* del fichero Info.plist. Se puede setear a partir de un valor del Build Settings. En nuestro caso lo haremos a partir del valor SDOSEnvironment

## [0.9.2 Soporte cambio de nombre de fichero encriptado](https://svrgitpub.sdos.es/iOS/SDOSEnvironment/tree/v0.9.2)

- Añadido nuevo parámetro "-validate *environment*". Este parámetro validará que existe un valoor valido para cada key en el entorno especificado

## [0.9.1 Soporte cambio de nombre de fichero encriptado](https://svrgitpub.sdos.es/iOS/SDOSEnvironment/tree/v0.9.1)

- Añadido soporte para cambiar el nombre del fichero con los parámetros encriptados

## [0.9.0 Primera versión de la librería](https://svrgitpub.sdos.es/iOS/SDOSEnvironment/tree/v0.9.0)

- Primera versión de la librería

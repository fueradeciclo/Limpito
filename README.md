# Limpito — actualizaciones de los TV Box

Cada TV Box preparado con Limpito 3.0+ revisa este repo al encender y cada 6 h. Si `versionCode`
de un componente es mayor que el instalado, baja el APK e instala, solo, sin que el dueño toque nada.

## Publicar una versión nueva

Desde la carpeta del repo, en la Mac:

```
./publicar.sh xuper  /ruta/al/XuperTv-nuevo.apk
./publicar.sh inicio /ruta/al/inicio.apk
```

El script valida el APK (para Xuper: que corra en estos boxes Android 7.1), lo copia a `apks/`,
sube el `versionCode` en `version.json` y hace commit + push. Listo.

## Reglas

- **Xuper es de terceros.** `validar-apk.sh` rechaza los que no traen `armeabi-v7a` o que verifican
  su firma con APIs de Android 9 (se cierran al abrir, como pasó con "Xuper Ar").
- **Inicio** (el launcher propio): al cambiarlo hay que subir su `versionCode` en
  `launcher/AndroidManifest.xml` antes de compilar, o los boxes no lo toman como nuevo.
- El repo tiene que quedar **público**: los boxes descargan sin usuario ni clave.

## Archivos

- `version.json` — lo que leen los boxes.
- `apks/` — los APK que se instalan.
- `validar-apk.sh`, `publicar.sh` — herramientas.

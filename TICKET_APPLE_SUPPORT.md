# Problema con la app en App Store Connect

App: App de Tarjeta Digital  
ID de App: 6754770379

---

Hola, necesito ayuda con esto. Tenemos un problema raro con nuestra app en App Store Connect.

## Lo que está pasando

Estamos usando Codemagic para compilar y subir la app. La compilación funciona bien y cuando subimos, nos dice que se subió exitosamente. Pero después, cuando vamos a TestFlight, no aparece nada. Nada de nada.

## Lo que está funcionando bien

- La compilación funciona sin problemas
- Cuando subimos, aparece el mensaje "UPLOAD SUCCEEDED" 
- El Bundle ID está bien (com.cgu.cguTarjeta) y coincide con la app
- La app existe en App Store Connect y está configurada
- Tenemos todo configurado para TestFlight

## El problema

Cada vez que subimos, vemos esto:

```
UPLOAD SUCCEEDED with 0 warnings, 0 messages
```

Perfecto, se subió. Pero cuando vamos a TestFlight... nada. No aparece ningún build. Ni uno que diga "Procesando", ni uno con error, ni nada. Como si nunca hubiéramos subido nada.

Ya intentamos subir varias veces y siempre pasa lo mismo. Sube exitosamente pero después no aparece en ningún lado.

## Qué debería pasar

Después de subir, deberíamos ver:
1. El build en TestFlight (aunque diga que está procesando)
2. Un email cuando esté listo
3. Poder probarlo en TestFlight

Pero nada de eso pasa. Se sube y después desaparece. No sabemos dónde está ni qué pasó.

## Lo que necesito saber

Básicamente necesito entender qué está pasando. ¿La app se está procesando en algún lado que no vemos? ¿Hay algún error que impide que aparezca? ¿Falta configurar algo? ¿Por qué los builds no aparecen aunque se suban bien?

Email: vitomuzio02@gmail.com

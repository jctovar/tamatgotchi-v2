# 📖 Manual de usuario — Tamagotchi

Bienvenido al manual de tu mascota virtual. Aquí aprenderás a manejar el dispositivo,
cuidar a tu mascota y entender cómo evoluciona.

---

## 1. El dispositivo

Tienes delante un Tamagotchi clásico:

- Una **pantalla LCD** verde (estilo Game Boy) donde vive tu mascota.
- **Tres botones físicos** debajo de la pantalla: **A**, **B** y **C**.

La pantalla muestra a tu mascota animada y, cuando abres el menú, una lista de opciones
de texto para elegir qué hacer.

---

## 2. Los botones

| Botón | Función |
|---|---|
| **A** | **Seleccionar.** Abre el menú la primera vez; después avanza al siguiente elemento del menú. |
| **B** | **Confirmar.** Ejecuta la acción del elemento de menú actualmente seleccionado. |
| **C** | **Cancelar / Estado.** Cierra el menú sin hacer nada. |

### Flujo típico

1. Pulsa **A** para abrir el menú.
2. Pulsa **A** repetidamente para moverte entre las opciones (el menú es circular: tras la
   última opción vuelves a la primera).
3. Cuando estés sobre la opción deseada, pulsa **B** para ejecutarla.
4. Pulsa **C** en cualquier momento para cerrar el menú.

---

## 3. El menú y los cuidados

El menú tiene estas opciones:

| Opción | Qué hace |
|---|---|
| 🍗 **Comida** | Alimenta a tu mascota. Sube el **hambre** (+20) y el **peso** (+0.5). |
| 💡 **Luz** | Enciende o apaga la luz. Útil para dormir. |
| 🎮 **Jugar** | Juega con tu mascota. Sube la **felicidad** (+15), pero gasta **hambre** (−5) y **peso** (−0.2). |
| 💊 **Medicina** | Cura a tu mascota. Sube la **salud** (+30). |
| 📊 **Estado** | (Reservado) Muestra el estado de la mascota. |
| 🕹️ **Juego** | (Reservado) Minijuego. |

> **Nota:** las opciones **Estado** y **Juego** están reservadas para futuras versiones y por
> ahora no realizan ninguna acción.

### Otras acciones

- **Limpiar** y **Dormir** son acciones internas que el sistema gestiona automáticamente
  (la limpieza mejora ligeramente la salud; dormir detiene el decaimiento mientras la mascota
  duerme).

---

## 4. Las estadísticas

Tu mascota tiene cuatro estadísticas principales (todas de 0 a 100, salvo el peso):

- 🍗 **Hambre:** qué tan saciada está. Baja con el tiempo.
- 😊 **Felicidad:** qué tan contenta está. Baja con el tiempo.
- ❤️ **Salud:** qué tan sana está. Si llega a **0**, la mascota muere.
- ⚖️ **Peso:** sube al comer, baja al jugar.

### Decaimiento con el tiempo

Las estadísticas bajan solas con el paso del tiempo, **incluso si cierras la app**:

| Estadística | Decaimiento por hora |
|---|---|
| Hambre | −4 |
| Felicidad | −3 |
| Salud | −1.5 |

> El sistema calcula el tiempo transcurrido desde la última vez que abriste la app y aplica el
> decaimiento de golpe al reabrir, con un **tope de 24 horas** (para que no muera de forma
> instantánea tras mucho tiempo cerrada).

> Mientras la mascota **duerme**, las estadísticas **no decaen**.

---

## 5. Etapas de evolución

Tu mascota evoluciona según su **edad**:

| Etapa | Edad |
|---|---|
| 🥚 **Huevo** | 0 – 5 minutos |
| 🐣 **Bebé** | 5 minutos – 24 horas |
| 🐥 **Niño** | 24 – 72 horas |
| 🐤 **Adolescente** | 72 – 168 horas (3–7 días) |
| 🐔 **Adulto** | 7 días en adelante |

El huevo eclosiona a los **5 minutos** de empezar. A partir de ahí, la mascota crece sola con
el tiempo.

---

## 6. Avisos y notificaciones

Cuando la app está en segundo plano o cerrada, el dispositivo puede avisarte:

- 🔔 **Hambre:** si el hambre baja de **40**, recibirás una notificación (~30 min después).
- 🔔 **Enfermedad:** si la salud baja de **30**, recibirás una notificación (~15 min después).

Al reabrir la app, las notificaciones pendientes se cancelan automáticamente y se recalcula el
estado de la mascota.

---

## 7. La luz y el sueño

- Usa la opción **Luz** para encenderla o apagarla.
- Apagar la luz y dejar dormir a la mascota **detiene el decaimiento** mientras duerme, pero
  recuerda despertarla y cuidarla después.

---

## 8. Muerte de la mascota

Si la **salud llega a 0**, la mascota muere y ya no puede ser cuidada. Para evitarlo:

- Aliméntala antes de que el hambre baje demasiado.
- Usa **Medicina** cuando su salud esté baja.
- No la descuides durante muchas horas seguidas.

---

## 9. Idiomas

El dispositivo está disponible en **Español, Inglés y Japonés**. El idioma sigue la
configuración regional de tu dispositivo.

---

## 10. Consejos rápidos

- ✅ Comprueba el **hambre** y la **felicidad** con regularidad.
- 💊 Ten a mano la **Medicina** cuando la salud baje de 30.
- 💾 El estado se guarda automáticamente: puedes cerrar la app sin perder el progreso.
- ⏳ El tiempo sigue contando aunque cierres la app — ¡vuelve pronto!

---

*¡Disfruta cuidando a tu Tamagotchi!* 🥚➡️🐔

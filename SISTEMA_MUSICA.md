# Sistema de Música Global - Godot

## Descripción General
Se ha implementado un sistema de música global para el juego que gestiona automáticamente la reproducción de música según el contexto del juego.

## Archivos Modificados/Creados

### 1. **AudioManager.gd** (NUEVO)
- **Ubicación**: `Codigo/AudioManager.gd`
- **Función**: Singleton global que gestiona toda la música del juego
- **Características**:
  - Reproduce música de fondo para niveles 1-3 (en loop)
  - Reproduce música del selector de personajes (en loop)
  - Reproduce música del boss final (sin loop, termina cuando el boss muere)
  - Persiste entre escenas para mantener la música continua

### 2. **project.godot** (MODIFICADO)
- Se agregó `AudioManager` como autoload para que esté disponible globalmente

### 3. **menu.gd** (MODIFICADO)
- Se agregó `_ready()` para reproducir la música del selector en el menú principal

### 4. **selector.gd** (MODIFICADO)
- Se agregó `_ready()` para reproducir la música del selector cuando se carga la pantalla
- Se agregó `AudioManager.play_background_music()` en cada botón de selección de personaje

### 5. **final_boss.gd** (MODIFICADO)
- Se agregó `AudioManager.play_finalboss_music()` en `_ready()` para iniciar la música del boss
- Se agregó `AudioManager.on_boss_defeated()` en `die()` para detener la música cuando el boss muere

### 6. **game_over.gd** (MODIFICADO)
- Se agregó `_ready()` para detener la música cuando se muestra la pantalla de Game Over

### 7. **winner.gd** (MODIFICADO)
- Se agregó `_ready()` para detener la música cuando se muestra la pantalla de victoria

## Flujo de Música

### 1. **Menú Principal**
```
Inicio del juego → AudioManager.play_selector_music()
Música: mus_selector.wav (LOOP)
```

### 2. **Selector de Personajes**
```
Pantalla de selector → AudioManager.play_selector_music()
Música: mus_selector.wav (LOOP)
```

### 3. **Niveles 1, 2 y 3**
```
Selección de personaje → AudioManager.play_background_music()
Música: mus_backgorund.wav (LOOP)
La música continúa automáticamente entre niveles
```

### 4. **Nivel del Boss Final**
```
Boss aparece → AudioManager.play_finalboss_music()
Música: mus_finalboss.wav (NO LOOP)
Boss muere → AudioManager.on_boss_defeated() → Música se detiene
```

### 5. **Game Over / Victoria**
```
Pantalla de Game Over o Victoria → AudioManager.stop_music()
Música: Ninguna (silencio)
```

## Funciones Principales del AudioManager

### `play_selector_music()`
Reproduce la música del selector de personajes en loop.

### `play_background_music()`
Reproduce la música de fondo para los niveles 1-3 en loop.

### `play_finalboss_music()`
Reproduce la música del boss final sin loop (termina cuando acaba la canción).

### `on_boss_defeated()`
Detiene la música del boss final cuando el jugador lo derrota.

### `stop_music()`
Detiene cualquier música que esté sonando actualmente.

## Notas Importantes

1. **Persistencia**: El AudioManager es un singleton que persiste entre escenas, por lo que la música continúa automáticamente cuando cambias de nivel.

2. **Loop Automático**: 
   - Música del selector: ✅ Loop infinito
   - Música de niveles 1-3: ✅ Loop infinito
   - Música del boss final: ❌ No loop (termina cuando el boss muere)

3. **Transiciones**: No necesitas agregar código adicional en las transiciones entre niveles 1→2→3, la música continúa automáticamente.

4. **Archivo de música**: Nota que hay un typo en el nombre del archivo: `mus_backgorund.wav` (debería ser "background"). Si quieres corregirlo, debes:
   - Renombrar el archivo en la carpeta Musica
   - Actualizar la constante `MUSIC_BACKGROUND` en `AudioManager.gd`

## Pruebas Recomendadas

1. **Menú Principal** → Verificar que suene la música del selector al iniciar el juego
2. **Selector de Personajes** → Verificar que continúe la música del selector
3. **Seleccionar personaje** → Verificar que cambie a música de fondo
4. **Nivel 1 → Nivel 2** → Verificar que la música continúe sin interrupciones
5. **Nivel 2 → Nivel 3** → Verificar que la música continúe sin interrupciones
6. **Nivel 3 → Boss Final** → Verificar que cambie a música del boss
7. **Derrotar al boss** → Verificar que la música se detenga
8. **Game Over** → Verificar que la música se detenga
9. **Victoria** → Verificar que la música se detenga
10. **Volver al selector desde Game Over/Victoria** → Verificar que vuelva a sonar la música del selector

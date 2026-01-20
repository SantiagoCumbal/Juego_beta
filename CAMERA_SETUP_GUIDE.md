# Guía de Configuración de Cámara - Sistema Mejorado

## Resumen de Cambios

Tu sistema de cámara ha sido mejorado para:
1. **Integración automática** con el sistema de selección de personajes
2. **Límites de mapa** que evitan que la cámara se salga de los bordes (como Hollow Knight)
3. **Seguimiento suave** con anticipación según la dirección del movimiento
4. **Soporte multi-nivel** con límites configurables por nivel

---

## Cómo Funciona

### 1. Flujo de Inicialización

```
Selector de Personajes
	↓
Global.selected_character_scene = "ruta/del/personaje.tscn"
	↓
Cargar Nivel (nivel_invocacion.gd)
	↓
Instanciar Personaje
	↓
Global.current_player = player (referencia guardada)
	↓
camera.set_player(player) (cámara comienza a seguir)
	↓
camera.set_camera_limits(...) (se aplican límites del mapa)
```

### 2. Archivos Modificados

#### **Global.gd**
- Ahora almacena `current_player` (referencia al jugador actual)
- Se actualiza cada vez que se instancia un nuevo personaje

#### **camara.gd**
- Busca al jugador desde `Global.current_player`
- Implementa seguimiento suave con anticipación
- Aplica límites de cámara automáticamente
- Incluye funciones públicas para control avanzado

#### **nivel_invocacion.gd**
- Instancia el personaje seleccionado
- Guarda la referencia en `Global.current_player`
- Configura la cámara automáticamente
- Detecta límites del mapa si existe un nodo "MapBounds"

---

## Características de la Cámara

### Seguimiento Suave
```gdscript
var follow_speed: float = 8.0  # Velocidad de suavizado
var look_ahead_distance: float = 50.0  # Anticipación de movimiento
var vertical_offset: float = -20.0  # Offset vertical (composición)
```

### Límites de Mapa
La cámara respeta los bordes del mapa y no se sale de ellos:
```gdscript
camera.set_camera_limits(
	left: 0.0,
	right: 1280.0,
	top: 0.0,
	bottom: 720.0
)
```

### Zoom Dinámico
```gdscript
camera.set_zoom_level(1.5)  # Zoom 1.5x
```

### Efecto de Temblor
```gdscript
camera.shake_camera(intensity: 5.0, duration: 0.3)
```

---

## Cómo Configurar Límites por Nivel

### Opción 1: Usando MapBounds (Recomendado)

En tu escena de nivel (en Godot Editor):
1. Crea un nodo `Area2D` llamado "MapBounds"
2. Añade un `CollisionShape2D` con un `RectangleShape2D`
3. Ajusta el tamaño del rectángulo al tamaño de tu mapa
4. El sistema detectará automáticamente los límites

### Opción 2: Valores Personalizados

En tu script de nivel, sobrescribe `_get_map_limits()`:

```gdscript
func _get_map_limits() -> Dictionary:
	return {
		"left": 0.0,
		"right": 2560.0,      # Ancho del mapa
		"top": 0.0,
		"bottom": 1440.0      # Alto del mapa
	}
```

---

## Transición Entre Niveles

Cuando cambies de nivel:

```gdscript
# En tu script de transición
Global.selected_character_scene = "res://personajes/Robot/robot.tscn"
get_tree().change_scene_to_file("res://niveles/nivel2.tscn")
```

El nuevo nivel:
1. Instancia el personaje
2. Guarda la referencia en `Global.current_player`
3. Configura la cámara automáticamente con los nuevos límites

---

## Funciones Públicas de la Cámara

```gdscript
# Cambiar el jugador a seguir
camera.set_player(new_player)

# Establecer límites del mapa
camera.set_camera_limits(left, right, top, bottom)

# Cambiar zoom
camera.set_zoom_level(1.5)

# Efecto de temblor
camera.shake_camera(intensity: 5.0, duration: 0.3)

# Pausar seguimiento
camera.stop_following()

# Reanudar seguimiento
camera.resume_following()
```

---

## Ajustes Recomendados

Para un comportamiento similar a **Hollow Knight**:

```gdscript
follow_speed: 8.0          # Suavizado moderado
look_ahead_distance: 50.0  # Buena anticipación
vertical_offset: -20.0     # Composición visual
```

Para un comportamiento más **rápido y directo**:

```gdscript
follow_speed: 15.0         # Más rápido
look_ahead_distance: 30.0  # Menos anticipación
vertical_offset: 0.0       # Centrado
```

---

## Solución de Problemas

### La cámara no sigue al jugador
- Verifica que `Global.current_player` esté establecido
- Asegúrate de que el nodo de cámara se llama `Camera2D`
- Revisa que `camera.make_current()` se ejecute

### La cámara se sale del mapa
- Verifica los límites en `set_camera_limits()`
- Asegúrate de que el tamaño del viewport sea correcto
- Revisa que el zoom no sea muy bajo

### El seguimiento es demasiado lento/rápido
- Ajusta `follow_speed` (valores más altos = más rápido)
- Ajusta `look_ahead_distance` para la anticipación

---

## Próximos Pasos

1. **Prueba el sistema** en tu primer nivel
2. **Ajusta los parámetros** según tu preferencia visual
3. **Configura MapBounds** en cada nivel para límites automáticos
4. **Añade efectos** como temblor en eventos importantes

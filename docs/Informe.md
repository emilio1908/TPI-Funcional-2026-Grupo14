## Informe Técnico Analítico

> Integrantes — Grupo 14 (UNNE): Gaitán Pereyra Julio Emilio · Gabaldo Zdanovicz Matías Nahuel · Bonessi Luis María · Rojas Ruth · Frias Juan Gabriel.

*Las secciones de Fase 1 y Fase 2 se encuentran aún en proceso.*

---

# Fase 3 — Estudio Comparativo: Common Lisp vs. Clojure

**Lenguaje asignado: Clojure.** Código fuente de las funciones reimplementadas: [`comparativa/solucion.clj`](../comparativa/solucion.clj).

## 1. Presentación breve del lenguaje

**Clojure** es un dialecto moderno de Lisp creado por **Rich Hickey** en **2007**. Es un lenguaje funcional, dinámico y de propósito general que se ejecuta principalmente sobre la **Máquina Virtual de Java (JVM)**, lo que le permite interoperar con todo el ecosistema de bibliotecas de Java. Existen además variantes que compilan a JavaScript (**ClojureScript**) y al CLR de .NET.

Sus pilares de diseño son:

- **Inmutabilidad por defecto:** sus colecciones (listas, vectores, mapas, conjuntos) son **estructuras de datos persistentes e inmutables**. Modificar una colección no la altera, sino que devuelve una versión nueva que comparte la mayor parte de su estructura con la original (*structural sharing*).
- **"Code as data" (homoiconicidad):** al igual que todo Lisp, el código es una estructura de datos del propio lenguaje, lo que habilita macros muy potentes.
- **Estados gestionados explícitamente:** cuando se necesita estado mutable, se hace de forma controlada y segura para concurrencia mediante `atom`, `ref`, `agent` y la *Software Transactional Memory (STM)*.
- **Keywords** (`:rojo`) como mecanismo idiomático y eficiente para etiquetar y mapear estados.

### Industrias y áreas donde se utiliza
- **Sistemas backend y de datos a gran escala** (procesamiento concurrente, *data engineering*, *streaming*).
- **Fintech y banca** (donde la inmutabilidad y la concurrencia segura reducen errores).
- **Desarrollo web full-stack** (Clojure en el servidor + ClojureScript en el navegador).
- **Análisis de datos y machine learning** sobre la JVM.

### Empresas conocidas que lo utilizan
- **Nubank** (el banco digital más grande de Latinoamérica; uno de los mayores usuarios de Clojure del mundo, adquirió incluso la empresa de Rich Hickey, Cognitect).
- **Walmart** (procesamiento de recibos y *e-commerce*).
- **Apple**, **Netflix**, **Cisco**, **Atlassian** y **CircleCI**, entre otras.

## 2. Funciones reimplementadas

Se reimplementaron **únicamente** las funciones `transicion` y `timer` (tomando como base la *Iteración 2* de `lisp/core.lisp`, con el estado `intermitente`), conservando los encabezados de clasificación obligatorios. El detalle completo, las variantes idiomáticas y los ejemplos de uso se encuentran en [`comparativa/solucion.clj`](../comparativa/solucion.clj). En resumen:

- `transicion`: se mantiene la estrategia de `cond` (idéntica a Lisp), pero los estados pasan de **símbolos cotizados** (`'en-rojo`) a **keywords** (`:en-rojo`) y el resultado se devuelve en un **vector inmutable** `[ ... ]` en lugar de una lista.
- `timer`: misma lógica pura basada en `(mod timestamp 225)` y `cond`, retornando keywords.

## 3. Respuestas a las preguntas teóricas (Clojure)

### Pregunta 1 — Ventaja técnica y de rendimiento de los Keywords frente a los símbolos cotizados

En Common Lisp un símbolo como `'en-rojo` se *internaliza* en un paquete y arrastra metadata propia de los símbolos (valor, función asociada, *property list*, paquete de origen). En Clojure los estados se modelan con **keywords** (`:en-rojo`), y esto ofrece ventajas concretas:

1. **Internamiento + caché global (rendimiento):** los keywords se *internan* una sola vez en una tabla global. Esto significa que dos apariciones de `:en-rojo` en cualquier parte del programa apuntan **al mismo objeto en memoria**. Por lo tanto la comparación de igualdad (`=`) se resuelve prácticamente como una **comparación de identidad/referencia (`identical?`)**, que es O(1) y muy barata — ideal para un `cond`/`case` que despacha sobre estados como hace `transicion`.

2. **Son auto-evaluables:** un keyword se evalúa a sí mismo, no necesita comillas (`'`). Esto elimina toda una clase de errores de *quoting* del Lisp clásico (olvidar el `'` y que el símbolo se intente evaluar como variable). En `transicion` se escribe directamente `:en-rojo`, no `':en-rojo`.

3. **Funcionan como funciones de búsqueda:** un keyword **es invocable** y sabe buscarse a sí mismo dentro de un mapa: `(:en-rojo {:en-rojo 90})` ⇒ `90`. Esto hace que mapear estados a tiempos sea extremadamente directo (`(estado tabla-de-tiempos)`), sin necesidad de funciones auxiliares.

4. **Despacho eficiente con `case`:** como los keywords se comparan en tiempo constante, la forma `case` (que en Clojure compila a un salto tipo *tabla hash* en O(1)) es la herramienta natural para mapear estados, como se muestra en la variante `transicion-case`.

En síntesis: el keyword es la estructura idiomática y de **costo constante** para representar y comparar estados, mientras que el símbolo cotizado es más pesado conceptual y operativamente.

### Pregunta 2 — Cómo maneja Clojure el paso del tiempo sin modificar variables

Clojure **prohíbe la mutación por defecto** y usa **estructuras de datos persistentes**, por lo que el "paso del tiempo" no se simula reasignando una variable global de estado (no existe `setf`/`setq`). En su lugar, **el tiempo es un dato que fluye como argumento**, exactamente igual que exige la consigna de inmutabilidad de la Fase 1. Hay tres formas idiomáticas, todas presentes en `solucion.clj`:

1. **El tiempo como argumento de una función pura:** `timer` no guarda estado; recibe el `timestamp` y devuelve el color correspondiente. La "línea de tiempo" completa es simplemente el resultado de evaluar `timer` para cada instante.

2. **Recursión de cola con `loop`/`recur` (`simular-ciclo`):** en lugar de un bucle que va *pisando* una variable contador, `recur` vuelve a entrar a la función con **nuevos valores ligados** (`(inc t)`, `(dec restantes)`). En cada paso se construye un vector acumulador con `conj`; gracias al *structural sharing*, cada `conj` produce una **versión nueva e inmutable** que comparte estructura con la anterior: la versión previa nunca se modifica. Además, `recur` garantiza la *Tail Call Optimization*, evitando el desbordamiento de pila.

3. **Funciones de orden superior sobre una secuencia perezosa (`simular-ciclo-hof`):** `(mapv timer (range t0 tn))` describe declarativamente "el color en cada instante del rango", sin contador mutable alguno.

Cuando un sistema **sí** necesita un estado vivo y mutable (por ejemplo, "cuál es el color *ahora mismo* en la intersección"), Clojure no rompe la inmutabilidad de los datos: encapsula la referencia en un **`atom`** y la actualiza con `swap!`/`reset!`. El valor que el `atom` apunta sigue siendo inmutable; lo único que cambia de forma atómica y segura para concurrencia es **a qué valor inmutable apunta la referencia**. Así se separa la *identidad* (la referencia) del *valor* (el estado inmutable en el tiempo), que es el modelo conceptual central de Clojure.

## 4. Conclusión del grupo

Estudiar Clojure resultó especialmente natural viniendo de Common Lisp: compartimos la sintaxis de paréntesis (S-expressions), la homoiconicidad y la filosofía funcional, por lo que la traducción de `transicion` y `timer` fue casi directa. Las diferencias que más nos marcaron fueron conceptuales más que sintácticas:

- El reemplazo de **símbolos cotizados por keywords** nos pareció una mejora clara de legibilidad y de rendimiento para modelar estados, además de eliminar errores típicos de *quoting*.
- La **inmutabilidad obligatoria** de Clojure formaliza y refuerza lo que en la Fase 1 tuvimos que imponernos como una *restricción de disciplina* en Lisp (no usar `setf`/`setq`): en Clojure es el comportamiento por defecto, no una regla que uno pueda olvidar.
- El uso de **vectores `[...]`** en lugar de listas para datos, y de `loop`/`recur` con garantía de TCO, nos dio una forma más segura y predecible de iterar sin bucles imperativos.

La principal curva de aprendizaje no estuvo en la sintaxis, sino en **cambiar la mentalidad** de "modificar una variable de estado" a "hacer fluir el estado como un valor inmutable a través de funciones". Una vez asimilado ese cambio, el código quedó más declarativo, más fácil de razonar y libre de efectos colaterales. La cercanía con la JVM y su adopción en empresas serias (Nubank, Walmart) nos mostró además que el paradigma funcional no es solo académico, sino plenamente productivo en la industria.

## 5. Bibliografía

- Sitio oficial de Clojure — https://clojure.org
- *Rationale* y guía de estructuras de datos persistentes — https://clojure.org/about/rationale
- Documentación de Keywords y colecciones — https://clojure.org/reference/data_structures
- *Special forms* (`recur`, `loop`) — https://clojure.org/reference/special_forms
- REPL en línea utilizado para pruebas — https://tryclojure.org/
- Casos de uso en industria (Nubank / Cognitect) — https://www.cognitect.com / https://nubank.com.br


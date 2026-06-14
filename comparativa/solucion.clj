;;;; ***************************************************
;;;; Fichero: solucion.clj
;;;; Proyecto: TRABAJO PRACTICO INTEGRADOR 2026 - Fase 3 (Estudio Comparativo)
;;;; Lenguaje asignado: CLOJURE
;;;; Grupo de trabajo: #14
;;;; Integrantes:
;;;;   - Gaitan Pereyra, Julio Emilio
;;;;   - Gabaldo Zdanovicz, Matias Nahuel
;;;;   - Bonessi, Luis Maria
;;;;   - Rojas, Ruth
;;;;   - Frias, Juan Gabriel
;;;; Universidad Nacional del Nordeste (UNNE)
;;;;
;;;; Consigna Fase 3: reimplementar UNICAMENTE las funciones `transicion` y `timer`
;;;; en el lenguaje asignado, conservando los comentarios de clasificacion.
;;;; Se toma como referencia la "ITERACION 2" del archivo lisp/core.lisp
;;;; (modelo de 4 estados con luz intermitente).
;;;; ***************************************************

(ns comparativa.solucion)

;; ========================================================
;; DIFERENCIA CLAVE CON COMMON LISP:
;; En Common Lisp los estados se modelan con SIMBOLOS COTIZADOS ('en-rojo).
;; En Clojure se modelan con KEYWORDS (:en-rojo), que son la forma idiomatica
;; y eficiente de representar estados/etiquetas (ver respuesta teorica 1).
;; ========================================================


;--------------------------------------------------------------------------------------------------------
; Requerimiento 1: Estados de Transicion

;; ========================================================
;; FUNCION: transicion
;; NATURALEZA: Pura (sin efectos secundarios; misma entrada -> misma salida)
;; ESTRATEGIA: Condicional mediante `cond` (equivalente al cond de Lisp)
;; IMPACTO: No destructiva (retorna un vector NUEVO e inmutable; no muta estructuras)
;; ========================================================

(defn transicion [color-actual cambiar-a]
  (cond
    (and (= color-actual :en-rojo)      (= cambiar-a :intermitente)) [color-actual "intermitente"]

    (and (= color-actual :intermitente) (= cambiar-a :verde))        [color-actual "Cambiar-a-verde"]

    (and (= color-actual :en-verde)     (= cambiar-a :intermitente)) [color-actual "intermitente"]

    (and (= color-actual :intermitente) (= cambiar-a :amarillo))     [color-actual "Cambiar-a-amarillo"]

    (and (= color-actual :en-amarillo)  (= cambiar-a :intermitente)) [color-actual "intermitente"]

    (and (= color-actual :intermitente) (= cambiar-a :rojo))         [color-actual "Cambiar-a-rojo"]

    :else [color-actual "Accion-por-defecto"]))


;; ----- Variante idiomatica equivalente usando pattern matching con `case` -----
;; ----- sobre el par de estados. Demuestra el estilo declarativo de Clojure. ---

;; ========================================================
;; FUNCION: transicion-case
;; NATURALEZA: Pura
;; ESTRATEGIA: Funcion Predicado / despacho por valor mediante `case`
;; IMPACTO: No destructiva (retorna un vector nuevo)
;; ========================================================

(defn transicion-case [color-actual cambiar-a]
  (case [color-actual cambiar-a]
    [:en-rojo :intermitente]      [color-actual "intermitente"]
    [:intermitente :verde]        [color-actual "Cambiar-a-verde"]
    [:en-verde :intermitente]     [color-actual "intermitente"]
    [:intermitente :amarillo]     [color-actual "Cambiar-a-amarillo"]
    [:en-amarillo :intermitente]  [color-actual "intermitente"]
    [:intermitente :rojo]         [color-actual "Cambiar-a-rojo"]
    [color-actual "Accion-por-defecto"]))


;--------------------------------------------------------------------------------------------------------
; Requerimiento 2: Temporizador Automatico

;; ========================================================
;; FUNCION: timer
;; NATURALEZA: Pura (dado un timestamp, siempre retorna el mismo color)
;; ESTRATEGIA: Condicional mediante `cond` sobre el segundo del ciclo (mod)
;; IMPACTO: No destructiva (solo lee el argumento; no muta estado)
;; ========================================================

(defn timer [timestamp]
  (let [segundo-ciclo (mod timestamp 225)]   ; ciclo total = 90 + 3 + 120 + 3 + 6 + 3 = 225 s
    (cond
      (<= segundo-ciclo 90)  :en-rojo
      (<= segundo-ciclo 93)  :intermitente
      (<= segundo-ciclo 213) :en-verde
      (<= segundo-ciclo 216) :intermitente
      (<= segundo-ciclo 222) :en-amarillo
      :else                  :intermitente)))


;--------------------------------------------------------------------------------------------------------
; APOYO TEORICO (Pregunta 2): paso del tiempo SIN mutar variables.
; En Clojure no reasignamos un "estado global". El tiempo fluye como ARGUMENTO
; de una recursion de cola (loop/recur), generando en cada paso una secuencia
; inmutable de colores. Esto responde a "como maneja el paso del tiempo el
; simulador sin modificar variables".

;; ========================================================
;; FUNCION: simular-ciclo
;; NATURALEZA: Pura (no imprime; construye y retorna datos)
;; ESTRATEGIA: Recursiva de Cola (Tail Recursion) mediante `loop`/`recur`
;; IMPACTO: No destructiva (acumula en un vector persistente; cada `conj` crea
;;          una nueva version estructuralmente compartida, no muta la anterior)
;; ========================================================

(defn simular-ciclo [t-inicial cantidad-segundos]
  (loop [t          t-inicial
         restantes  cantidad-segundos
         acumulado  []]
    (if (zero? restantes)
      acumulado
      (recur (inc t)
             (dec restantes)
             (conj acumulado [t (timer t)])))))


;; ========================================================
;; Variante con FUNCION DE ORDEN SUPERIOR (mapv) sobre un rango.
;; Mismo resultado, estilo aun mas declarativo y sin recursion explicita.
;; ========================================================

;; ========================================================
;; FUNCION: simular-ciclo-hof
;; NATURALEZA: Pura
;; ESTRATEGIA: Funciones de Orden Superior (`mapv` + `range`)
;; IMPACTO: No destructiva
;; ========================================================

(defn simular-ciclo-hof [t-inicial cantidad-segundos]
  (mapv (fn [t] [t (timer t)])
        (range t-inicial (+ t-inicial cantidad-segundos))))


;--------------------------------------------------------------------------------------------------------
; Requerimiento 7 (parcial): Aseguramiento de la calidad - Ejemplos de uso
; Para ejecutar: copiar y pegar en un REPL de Clojure (https://tryclojure.org/)
;--------------------------------------------------------------------------------------------------------

(comment
  ;; ========== transicion ==========
  ;; Funcionamiento NORMAL:
  (transicion :en-rojo :intermitente)      ; => [:en-rojo "intermitente"]
  (transicion :intermitente :verde)        ; => [:intermitente "Cambiar-a-verde"]
  (transicion :en-verde :intermitente)     ; => [:en-verde "intermitente"]
  (transicion :intermitente :amarillo)     ; => [:intermitente "Cambiar-a-amarillo"]

  ;; Camino ALTERNATIVO (transicion no contemplada):
  (transicion :amarillo :rojo)             ; => [:amarillo "Accion-por-defecto"]

  ;; Caso de ERROR (aridad incorrecta):
  ;; (transicion :en-rojo)
  ;; => Execution error (ArityException) Wrong number of args (1) passed to: transicion

  ;; La variante con case devuelve lo mismo:
  (transicion-case :intermitente :verde)   ; => [:intermitente "Cambiar-a-verde"]

  ;; ========== timer ==========
  ;; Funcionamiento NORMAL:
  (timer 1000)   ; => :en-verde   (1000 mod 225 = 100)
  (timer 225)    ; => :en-rojo    (225 mod 225 = 0)
  (timer 50)     ; => :en-rojo
  (timer 200)    ; => :en-verde

  ;; Camino ALTERNATIVO (zona intermitente / amarillo):
  (timer 92)     ; => :intermitente
  (timer 220)    ; => :en-amarillo

  ;; Caso de ERROR (argumento no numerico):
  ;; (timer "hola")
  ;; => Execution error (ClassCastException) String cannot be cast to Number

  ;; ========== simulacion del paso del tiempo (inmutable) ==========
  (simular-ciclo 88 6)
  ;; => [[88 :en-rojo] [89 :en-rojo] [90 :en-rojo]
  ;;     [91 :intermitente] [92 :intermitente] [93 :intermitente]]

  (simular-ciclo-hof 88 6)   ; => mismo resultado que simular-ciclo
  )

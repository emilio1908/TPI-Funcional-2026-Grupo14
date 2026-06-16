;;;; 
***************************************************
;;;; Fichero: core.lisp 
;;;; Fecha-de-creación: 01/06/2026 
;;;; Proyeco: TRABAJO PRACTICO INTEGRADOR
;;;; Comentarios: Este fichero corresponde al desarrollo de un "Sistema de Semáforos Inteligentes". 
;;;; Grupo de trabajo: #14
;;;; Integrantes:
;;;;   - Gaitán Pereyra, Julio Emilio 
;;;;   - Gabaldo Zdanovicz, Matias Nahuel 
;;;;   - Bonessi, Luis Maria
;;;;   - Rojas, Ruth
;;;;   - Frias, Juan Gabriel
;;;;  Universidad Nacional del Nordeste (UNNE)
;;;; 
***************************************************

;;; ========================================================
;;; Restricciones de Diseño e Implementación:

;;; 1_ Inmutabilidad absoluta: *Sin variables globales mutables (defparameter, defvar)
;;;                            *Sin operadores destructivos (setq, setf)

;;; 2_ Cero bucles imperativos: *No se permite (loop, dolist, dotimes, while)
;;; ========================================================


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Contexto del Problema:
; Las ciudades modernas requieren sistemas de tráfico inteligentes para optimizar el flujo vehicular y garantizar la seguridad vial. Su equipo ha sido contratado para desarrollar 
; el núcleo lógico de un sistema embebido que controlará semáforos en intersecciones críticas de la ciudad. El mismo fue implementado en Common Lisp.

; Requerimiento 1: Estados de Transición
; Implemente la función transicion que modele el cambio de estados del semáforo.

;; ========================================================
;; FUNCIÓN: transicion
;; NATURALEZA: Pura (Dado un color actual y uno nuevo, siempre retorna la misma acción)
;; ESTRATEGIA: Condicional (Implementada mediante cond y comparaciones con equal)
;; IMPACTO: No destructiva (Solo describe la transición, sin alterar datos externos)
;; ========================================================

(defun transicion (color-actual cambiar-a)
  (cond
    ((and (equal  color-actual 'en-rojo) (equal  cambiar-a 'verde)) (list color-actual  "Cambiar-a-verde"))
    ((and (equal  color-actual 'en-amarillo) (equal  cambiar-a 'rojo )) (list color-actual "Cambiar-a-rojo"))
    ((and  (equal  color-actual 'en-verde) (equal  cambiar-a 'amarillo )) (list color-actual "Cambiar-a-amarillo"))
    (t (list color-actual "Accion-por-defecto"))
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 2: Temporizador Automático
; Para la implementación de un actuador que realizará el cambio de luces se necesita implementar un mecanismo automatizado de temporización. Se solicita implementar una función Timer, 
; que recibirá el tiempo actual en formato tiempo Unix (o tiempo epoch). Desarrolle la función timer para automatizar las transiciones basadas en tiempo Unix.

;; ========================================================
;; FUNCIÓN: timer
;; NATURALEZA: Pura (Dado un timestamp, siempre retorna el mismo color del ciclo)
;; ESTRATEGIA: Implementada mediante let y cond
;; IMPACTO: No destructiva (Solo calcula el estado del semáforo, sin alterar datos externos)
;; ========================================================

(defun timer (timestamp)
  (let ((segundo-ciclo (mod timestamp 216)))
    (cond 
      ((<= segundo-ciclo 90) 'en-rojo)
      ((<= segundo-ciclo 96) 'en-amarillo)
      (t 'en-verde)
    )
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 3: Sistema de Auditoría
; El equipo de analistas forenses necesita poder determinar qué color tenía una luz a determinada hora. Se necesita implementar un mecanismo de registro de los diferentes cambios de 
; estado de las luces durante la ejecución del programa. Se ha solicitado que para la versión actual se implemente una función que imprima en la terminal de ejecución el cambio de 
; estados del semáforo. Implemente un mecanismo de logging para análisis forense de tráfico.

;; ========================================================
;; FUNCIÓN: registro-de-estados
;; NATURALEZA: Impura (Genera efectos externos al imprimir en consola)
;; ESTRATEGIA: Implementada mediante format y local-time:format-timestring)
;; IMPACTO: No destructiva (Solo registra cambios de estado, no altera datos internos)
;; ========================================================

(defun registro-de-estados (color-anterior color-nuevo)
  (format t
          "[~A] la luz ha cambiado de ~A a ~A~%"
          (local-time:format-timestring ; toma el timestamp y lo transforma en texto.
           nil
           (local-time:now) ; Devuelve un timestamp interno de la libreria.
           :format '((:year 4) ; formato de fecha hora y fecha
                     "-"
                     (:month 2)
                     "-"
                     (:day 2)
                     " "
                     (:hour 2)
                     ":"
                     (:min 2)
                     ":"
                     (:sec 2))
          )
          color-anterior
          color-nuevo
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 4: Análisis de Ciclos Semafóricos
; Para la coordinación y planificación de la vía se necesita calcular cuántos ciclos, transición entre rojo a rojo, se realizarán pasado un determinado tiempo. A la hora de determinar 
; la duración de un ciclo semafórico se acostumbra a tener en cuenta la psicología del conductor, según la cual, ciclos menores de 35 segundos o mayores de 150 segundos se acomodan 
; difícilmente a la mentalidad del usuario de la vía pública, por lo que tienden a evitarse. Por lo que se solicita implementar una función duracion-ciclo que calcule la duración que 
; tendrá cada ciclo con las reglas de negocio actuales y una funcion de recomendacion sobre la duración del ciclo. Desarrolle funciones para análisis de eficiencia del sistema:
; a) Funcion duracion-ciclo y b) Funcion recomendacion-ciclo

;; ========================================================
;; FUNCIÓN: duracion-ciclo
;; NATURALEZA: Pura (depende solo de los parámetros de entrada, no modifica estado)
;; ESTRATEGIA: Uso de let para definir duración total del ciclo y floor para calcular ciclos completos
;; IMPACTO: No destructiva (retorna lista con número de ciclos y recomendación, no altera variables globales)
;; ========================================================
  
(defun duracion-ciclo (segundos)
  (let ((duracion-ciclo-total (+ 90 6 120))) ; ROJO: 90seg - AMARILLO: 6seg - VERDE: 120seg
    (list (abs (floor segundos duracion-ciclo-total)) ; número de ciclos completos sobre el total del ciclo 
          (recomendacion-ciclo segundos) ; recomendación sobre la duración
    )
  )
)   

;; ========================================================
;; FUNCIÓN: recomendacion-ciclo
;; NATURALEZA: Pura (depende solo del parámetro de entrada, no modifica estado)
;; ESTRATEGIA: Condicional con verificación de tipo (integerp) y rangos
;; IMPACTO: No destructiva (retorna lista con evaluación y recomendación, no altera variables globales)
;; ========================================================

(defun recomendacion-ciclo (duracion)
  (cond
    ((and (integerp duracion) (< duracion 35)) (list "Rango NO-optimo:" 'ciclo-corto "recomendacion:" 'aumentar-duracion))
    ((and (integerp duracion) (> duracion 150)) (list "Rango NO-optimo:" 'ciclo-largo "recomendacion:" 'aumentar-duracion))
    ((integerp duracion) (list "Rango Optimo" "recomendacion:" 'Ninguna))
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 5: Planificación Temporal
; Para la coordinación y planificación de la vía se necesita calcular cuantos ciclos se completan en determinada cantidad de minutos, por ejemplo en 15 minutos; se requiere una función 
; ciclos-por-tiempo que calcule la cantidad de ciclos incluidos en ese tiempo.

;; ========================================================
;; FUNCIÓN: ciclos-por-tiempo
;; NATURALEZA: Pura (depende solo de los parámetros de entrada, no modifica estado)
;; ESTRATEGIA: Conversión de minutos a segundos y división entera con floor
;; IMPACTO: No destructiva (retorna número de ciclos completos, no altera variables globales)
;; ========================================================

(defun ciclos-por-tiempo(minutos)
  (let ((duracion-ciclo-total (+ 90 6 120))) ; ROJO: 90seg - AMARILLO: 6seg - VERDE: 120seg
      (abs (floor (* minutos 60) duracion-ciclo-total))
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 6: Informe de Distribución Temporal
; Por cuestiones de planificación logística, se necesita un informe que indique el porcentaje de cada color que se tendrá en 1 hora. Dadas ciertas reglas de negocios o según las actuales. 
; Desarrolle una función que calcule la distribución porcentual de cada color en períodos de 1 


;; ========================================================
;; FUNCIÓN: distribucion_porcentual
;; NATURALEZA: Pura (Dado un ciclo fijo, siempre retorna los mismos porcentajes)
;; ESTRATEGIA: Orden Superior (Implementada mediante let*, mapcar y lambda)
;; IMPACTO: No destructiva (Solo calcula proporciones de tiempos de colores)
;; ========================================================
(defun distribucion_porcentual ()
  
  (let* ((duracion-ciclo-total (+ 90 6 120)) ; variable 1: ROJO: 90seg - AMARILLO: 6seg - VERDE: 120seg

        (duracion-en-una-hora (* 3600 duracion-ciclo-total)) ; variable 2: calcula la duracion total del ciclo completo en una hora. "Devuelve el total en seg".

        (porcentajes (mapcar (lambda (d) (* (float (/ (* d 3600) duracion-en-una-hora)) 100)) ; variable 3: calcula porcentajes de cada color del ciclo en una hora.
                      (list 90 6 120))
        ))
    (list
      (list 'en-rojo     (first porcentajes))
      (list 'en-amarillo (second porcentajes))
      (list 'en-verde    (third porcentajes))
    )
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 7: Aseguramiento de la calidad
; El equipo de control de calidad ha solicitado que para cada uno de los requerimientos anteriores deberá proveer ejemplos de uso que demuestren el funcionamiento normal, ejemplos de 
; caminos alternativos (si los hubiere) y ejemplos que generan errores. A sabiendas de que el equipo ejecutará lo indicado, copiando y pegando.

ejemplos...

;;; ========== REQUERIMIENTO 1: transicion ==========

;;; Funcionamiento NORMAL:
;;; valor ingresado -> (transicion 'en-rojo 'verde)
;;; valor devuelto  -> (EN-ROJO "Cambiar-a-verde")

;;; valor ingresado -> (transicion 'en-amarillo 'rojo)
;;; valor devuelto  -> (EN-AMARILLO "Cambiar-a-rojo")

;;; valor ingresado -> (transicion 'en-verde 'amarillo)
;;; valor devuelto  -> (EN-VERDE "Cambiar-a-amarillo")

;;; Funcionamiento con camino ALTERNATIVO:
;;; valor ingresado -> (transicion 'amarillo 'rojo)
;;; valor devuelto  -> (AMARILLO "Accion-por-defecto")

;;; Caso de ejemplo de ERROR:
;;; valor ingresado -> (transicion 'en-rojo)
;;; valor devuelto  -> *** - invalid number of arguments: 1


;;; ========== REQUERIMIENTO 2: timer ==========

;;; Funcionamiento NORMAL:
;;; valor ingresado -> (timer 1000)
;;; valor devuelto  -> EN-VERDE

;;; valor ingresado -> (timer 216)
;;; valor devuelto  -> EN-ROJO

;;; Funcionamiento con camino ALTERNATIVO:
;;; valor ingresado -> (timer 95)
;;; valor devuelto  -> EN-AMARILLO

;;; Caso de ejemplo de ERROR:
;;; valor ingresado -> (timer hola)
;;; valor devuelto  -> *** - SYSTEM::READ-EVAL-PRINT: variable HOLA has no value


;;; ========== REQUERIMIENTO 3: registrar-cambio ==========

;;; Funcionamiento NORMAL:
;;; valor ingresado -> (registrar-cambio 90 'en-rojo 'en-verde)
;;; valor devuelto  -> Tiempo 90: la luz ha cambiado de EN-ROJO a EN-VERDE

;;; Funcionamiento con camino ALTERNATIVO:
;;; valor ingresado -> (registrar-cambio 10000 'en-rojo 'en-verde)
;;; valor devuelto  -> Tiempo 10000: la luz ha cambiado de EN-ROJO a EN-VERDE

;;; valor ingresado -> (registrar-cambio 90.5 'en-rojo 'en-verde)
;;; valor devuelto  -> Tiempo 90.5: la luz ha cambiado de EN-ROJO a EN-VERDE

;;; Caso de ejemplo de ERROR / LIMITE:
;;; valor ingresado -> (registrar-cambio -10 'en-rojo 'en-verde)
;;; valor devuelto  -> Tiempo -10: la luz ha cambiado de EN-ROJO a EN-VERDE
;;; (no produce error, pero un timestamp negativo no tiene sentido en el dominio)

;;; valor ingresado -> (registrar-cambio 100 nil 'en-verde)
;;; valor devuelto  -> Tiempo 100: la luz ha cambiado de NIL a EN-VERDE
;;; (no produce error, pero NIL como "color anterior" es semánticamente inválido)

;;; ========== REQUERIMIENTO 4: duracion-ciclo / recomendacion-ciclo ==========

;;; Funcionamiento NORMAL:
;;; valor ingresado -> (duracion-ciclo 32747)
;;; valor devuelto  -> (151 ("Rango NO-optimo:" CICLO-LARGO "recomendacion:" AUMENTAR-DURACION))

;;; Funcionamiento con camino ALTERNATIVO:
;;; valor ingresado -> (duracion-ciclo 3172.3)
;;; valor devuelto  -> (14 NIL)

;;; Caso de ejemplo de ERROR:
;;; valor ingresado -> (duracion-ciclo 'treintaycuatro)
;;; valor devuelto  -> *** - FLOOR: TREINTAYCUATRO is not a real number

;;; ========== REQUERIMIENTO 5: ciclos-por-tiempo ==========

;;; Funcionamiento NORMAL:
;;; valor ingresado -> (ciclos-por-tiempo 32)
;;; valor devuelto  -> 8

;;; Funcionamiento con camino ALTERNATIVO:
;;; valor ingresado -> (ciclos-por-tiempo 50.05)
;;; valor devuelto  -> 13

;;; Caso de ejemplo de ERROR:
;;; valor ingresado -> (ciclos-por-tiempo 'trescientostreinta)
;;; valor devuelto  -> *** - *: TRESCIENTOSTREINTA is not a number


;;; ========== REQUERIMIENTO 6: distribucion_porcentual ==========

;;; Funcionamiento NORMAL:
;;; valor ingresado -> (distribucion_porcentual 90 6 120)
;;; valor devuelto  -> ((EN-ROJO 41.666664) (EN-AMARILLO 2.7777777) (EN-VERDE 55.55556))

;;; Funcionamiento con camino ALTERNATIVO:
;;; valor ingresado -> (distribucion_porcentual 72 72 72)
;;; valor devuelto  -> ((EN-ROJO 33.333332) (EN-AMARILLO 33.333332) (EN-VERDE 33.333332))

;;; Caso de ejemplo de ERROR:
;;; valor ingresado -> (distribucion_porcentual 0 0 0)
;;; valor devuelto  -> *** - DIVISION-BY-ZERO

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------
******************** ITERACION 2 ********************
-----------------------------------------------------
; Extensión 1: Intermitencia de Seguridad

; Requerimiento 1: Estados de Transición

;; ========================================================
;; FUNCIÓN: transicion
;; NATURALEZA: Pura
;; ESTRATEGIA: Evaluación de transiciones mediante cond
;; IMPACTO: No destructiva
;; ========================================================

(defun transicion (color-actual cambiar-a)
  (cond
    ((and (equal  color-actual 'en-rojo) (equal  cambiar-a 'intermitente)) (list color-actual  "intermitente"))

    ((and (equal  color-actual 'intermitente) (equal  cambiar-a 'verde)) (list color-actual  "Cambiar-a-verde"))

    ((and (equal  color-actual 'en-verde) (equal  cambiar-a 'intermitente )) (list color-actual "intermitente"))

    ((and (equal  color-actual 'intermitente) (equal  cambiar-a 'amarillo )) (list color-actual "Cambiar-a-amarillo"))

    ((and (equal  color-actual 'en-amarillo) (equal  cambiar-a 'intermitente )) (list color-actual "intermitente"))

    ((and (equal  color-actual 'intermitente) (equal  cambiar-a 'rojo )) (list color-actual "Cambiar-a-rojo"))

    (t (list color-actual "Accion-por-defecto"))
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 2: Temporizador Automático

;; ========================================================
;; FUNCIÓN: timer
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional mediante cond
;; IMPACTO: No destructiva
;; ========================================================

(defun timer (timestamp)
  (let ((segundo-ciclo (mod timestamp 225)))
    (cond 
      ((<= segundo-ciclo 90) 'en-rojo)
      ((<= segundo-ciclo 93) 'intermitente)
      ((<= segundo-ciclo 213) 'en-verde)
      ((<= segundo-ciclo 216) 'intermitente)
      ((<= segundo-ciclo 222) 'en-amarillo)
      (t 'intermitente)
    )
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 3: Sistema de Auditoría

;; ========================================================
;; FUNCIÓN: registro-de-estados
;; NATURALEZA: Impura
;; ESTRATEGIA: Impresión mediante format
;; IMPACTO: No destructiva
;; ========================================================

(defun registro-de-estados (color-anterior color-nuevo)
  (format t
          "[~A] la luz ha cambiado de ~A a ~A~%"
          (local-time:format-timestring ; toma el timestamp y lo transforma en texto.
           nil
           (local-time:now) ; Devuelve un timestamp interno de la libreria.
           :format '((:year 4) ; formato de fecha hora y fecha
                     "-"
                     (:month 2)
                     "-"
                     (:day 2)
                     " "
                     (:hour 2)
                     ":"
                     (:min 2)
                     ":"
                     (:sec 2))
          )
          color-anterior
          color-nuevo
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 4: Análisis de Ciclos Semafóricos

;; ========================================================
;; FUNCIÓN: duracion-ciclo
;; NATURALEZA: Pura (depende solo de los parámetros de entrada, no modifica estado)
;; ESTRATEGIA: Uso de let para definir duración total del ciclo y floor para calcular ciclos completos
;; IMPACTO: No destructiva (retorna lista con número de ciclos y recomendación, no altera variables globales)
;; ========================================================

(defun duracion-ciclo (segundos)
  (let ((duracion-ciclo-total (+ 90 6 120 9))) ; ROJO: 90seg - AMARILLO: 6seg - VERDE: 120seg - INTERMITENCIA: 9s
    (list (floor segundos duracion-ciclo-total) ; número de ciclos completos sobre el total del ciclo 
          (recomendacion-ciclo segundos) ; recomendación sobre la duración
    )
  )
)     

;; ========================================================
;; FUNCIÓN: recomendacion-ciclo
;; NATURALEZA: Pura (depende solo del parámetro de entrada, no modifica estado)
;; ESTRATEGIA: Condicional con verificación de tipo (integerp) y rangos
;; IMPACTO: No destructiva (retorna lista con evaluación y recomendación, no altera variables globales)
;; ========================================================

(defun recomendacion-ciclo (duracion)
  (cond
    ((and (integerp duracion) (< duracion 35)) (list "Rango NO-optimo:" 'ciclo-corto "recomendacion:" 'aumentar-duracion))
    ((and (integerp duracion) (> duracion 150)) (list "Rango NO-optimo:" 'ciclo-largo "recomendacion:" 'aumentar-duracion))
    ((integerp duracion) (list "Rango Optimo" "recomendacion:" 'Ninguna))
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 5: Planificación Temporal

;; ========================================================
;; FUNCIÓN: ciclos-por-tiempo
;; NATURALEZA: Pura (depende solo de los parámetros de entrada, no modifica estado)
;; ESTRATEGIA: Conversión de minutos a segundos y división entera con floor
;; IMPACTO: No destructiva (retorna número de ciclos completos, no altera variables globales)
;; ========================================================

(defun ciclos-por-tiempo(minutos)
  (let ((duracion-ciclo-total (+ 90 6 120 9))) ; ROJO: 90seg - AMARILLO: 6seg - VERDE: 120seg - INTERMITENCIA: 9s
      (list (floor (* minutos 60) duracion-ciclo-total))
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 6: Informe de Distribución Temporal

;; ========================================================
;; FUNCIÓN: distribucion_porcentual
;; NATURALEZA: Pura (Dado un ciclo fijo, siempre retorna los mismos porcentajes)
;; ESTRATEGIA: Orden Superior (Implementada mediante let*, mapcar y lambda)
;; IMPACTO: No destructiva (Solo calcula proporciones de tiempos de colores)
;; ========================================================

(defun distribucion_porcentual ()
  
  (let* ((duracion-ciclo-total (+ 90 6 120 9)) ; variable 1: ROJO: 90seg - AMARILLO: 6seg - VERDE: 120seg - INTERMITENCIA: 9s

        (duracion-en-una-hora (* 3600 duracion-ciclo-total)) ; variable 2: calcula la duracion total del ciclo completo en una hora. "Devuelve el total en seg".

        (porcentajes (mapcar (lambda (d) (* (float (/ (* d 3600) duracion-en-una-hora)) 100)) ; variable 3: calcula porcentajes de cada color del ciclo en una hora.
                      (list 90 6 120 9))
        ))
    (list
      (list 'en-rojo     (first porcentajes))
      (list 'en-amarillo (second porcentajes))
      (list 'en-verde    (third porcentajes))
      (list 'en-intermitente (fourth porcentajes))
    )
  )
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;Extensión 2: Persistencia de Datos

;; --------------------------------------------------------
;; FUNCIÓN: informe
;; NATURALEZA: Impura (Genera efectos externos al escribir en un archivo)
;; ESTRATEGIA: Entrada/Salida (Implementada mediante with-open-file, format y mapcar)
;; IMPACTO: Destructiva controlada (Sobrescribe/crea archivo de informe con transiciones)
;; --------------------------------------------------------

(defun informe (datos)
  (with-open-file (stream ; Usa with-open-file para abrir (o crear) el archivo.
                   "informe-ejecucion-semaforo.txt"
                   :direction :output ; Abre el archivo para escritura.
                   :if-exists :supersede ; Si ya existe, lo sobrescribe.
                   :if-does-not-exist :create) ; Si no existe, lo crea.

    (format stream
            "Informe de Ejecución del Sistema Semafórico~%")

    (format stream
            "=========================================~%")

    (mapcar
      (lambda (transicion)

        (format stream
                "~A - Transición: ~A -> ~A~%"
                (local-time:format-timestring
                 nil
                 (local-time:unix-to-timestamp (car transicion)) ; Extrae el timestamp (tiempo unix) y luego lo convierte en hora y fecha legible.
                 :format '((:year 4)
                           "-"
                           (:month 2)
                           "-"
                           (:day 2)
                           " "
                           (:hour 2)
                           ":"
                           (:min 2)
                           ":"
                           (:sec 2)))

                (cadr transicion) ; Extrae el color actual.
                (caddr transicion))) ; Extrae el color al que se cambia.

      datos)

    (format stream
            "~%--- Fin del Informe ---")
  )
)






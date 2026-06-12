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
;; NATURALEZA: Pura
;; ESTRATEGIA: Evaluación de transiciones mediante cond
;; IMPACTO: No destructiva
;; ========================================================

(defun transicion (color-actual cambiar-a)
(cond 
((and (equal  color-actual 'en-rojo) (equal  cambiar-a 'verde)) (list color-actual  "Cambiar-a-verde"))
((and (equal  color-actual 'en-amarillo) (equal  cambiar-a 'rojo )) (list color-actual "Cambiar-a-rojo"))
((and  (equal  color-actual 'en-verde) (equal  cambiar-a 'amarillo )) (list color-actual "Cambiar-a-amarillo"))
(t (list color-actual "Accion-por-defecto"))))

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 2: Temporizador Automático
; Para la implementación de un actuador que realizará el cambio de luces se necesita implementar un mecanismo automatizado de temporización. Se solicita implementar una función Timer, 
; que recibirá el tiempo actual en formato tiempo Unix (o tiempo epoch). Desarrolle la función timer para automatizar las transiciones basadas en tiempo Unix.

;; ========================================================
;; FUNCIÓN: timer
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional mediante cond
;; IMPACTO: No destructiva
;; ========================================================

(EN-ROJO "Accion-por-defecto")
Break 1 [3]> (defun timer (timestamp)
(let ((segundo-ciclo (mod timestamp 216)))
(cond 
((< segundo-ciclo 90) 'en-rojo)
((< segundo-ciclo 96) 'en-amarillo)
(t 'en-verde))))

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 3: Sistema de Auditoría
; El equipo de analistas forenses necesita poder determinar qué color tenía una luz a determinada hora. Se necesita implementar un mecanismo de registro de los diferentes cambios de 
; estado de las luces durante la ejecución del programa. Se ha solicitado que para la versión actual se implemente una función que imprima en la terminal de ejecución el cambio de 
; estados del semáforo. Implemente un mecanismo de logging para análisis forense de tráfico.

;; ========================================================
;; FUNCIÓN: registro-de-estados
;; NATURALEZA: Impura
;; ESTRATEGIA: Impresión mediante format
;; IMPACTO: No destructiva
;; ========================================================

(defun registro-de-estados (timestamp color-anterior color-nuevo)
  (format t
          "Tiempo ~A: la luz ha cambiado de ~A a ~A~%"
          timestamp
          color-anterior
          color-nuevo))

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 4: Análisis de Ciclos Semafóricos
; Para la coordinación y planificación de la vía se necesita calcular cuántos ciclos, transición entre rojo a rojo, se realizarán pasado un determinado tiempo. A la hora de determinar 
; la duración de un ciclo semafórico se acostumbra a tener en cuenta la psicología del conductor, según la cual, ciclos menores de 35 segundos o mayores de 150 segundos se acomodan 
; difícilmente a la mentalidad del usuario de la vía pública, por lo que tienden a evitarse. Por lo que se solicita implementar una función duracion-ciclo que calcule la duración que 
; tendrá cada ciclo con las reglas de negocio actuales y una funcion de recomendacion sobre la duración del ciclo. Desarrolle funciones para análisis de eficiencia del sistema:
; a) Funcion duracion-ciclo y b) Funcion recomendacion-ciclo

;; ========================================================
;; FUNCIÓN: duracion-ciclo
;; NATURALEZA: ...
;; ESTRATEGIA: ...
;; IMPACTO: ...
;; ========================================================

(defun duracion-ciclo()
  cuerpo...
)

;; ========================================================
;; FUNCIÓN: recomendacion-ciclo
;; NATURALEZA: ...
;; ESTRATEGIA: ...
;; IMPACTO: ...
;; ========================================================

(defun recomendacion-ciclo()
  cuerpo...
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 5: Planificación Temporal
; Para la coordinación y planificación de la vía se necesita calcular cuantos ciclos se completan en determinada cantidad de minutos, por ejemplo en 15 minutos; se requiere una función 
; ciclos-por-tiempo que calcule la cantidad de ciclos incluidos en ese tiempo.

;; ========================================================
;; FUNCIÓN: ciclos-por-tiempo
;; NATURALEZA: ...
;; ESTRATEGIA: ...
;; IMPACTO: ...
;; ========================================================

(defun ciclos-por-tiempo()
  cuerpo...
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 6: Informe de Distribución Temporal
; Por cuestiones de planificación logística, se necesita un informe que indique el porcentaje de cada color que se tendrá en 1 hora. Dadas ciertas reglas de negocios o según las actuales. 
; Desarrolle una función que calcule la distribución porcentual de cada color en períodos de 1 hora

;; ========================================================
;; FUNCIÓN: distribucion_porcentual
;; NATURALEZA: ...
;; ESTRATEGIA: ...
;; IMPACTO: ...
;; ========================================================

(defun distribucion_porcentual()
  cuerpo...
)

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Requerimiento 7: Aseguramiento de la calidad
; El equipo de control de calidad ha solicitado que para cada uno de los requerimientos anteriores deberá proveer ejemplos de uso que demuestren el funcionamiento normal, ejemplos de 
; caminos alternativos (si los hubiere) y ejemplos que generan errores. A sabiendas de que el equipo ejecutará lo indicado, copiando y pegando.

ejemplos...










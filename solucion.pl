% puedeCumplir(Persona, Rol): relaciona una persona con un rol que puede cumplir
puedeCumplir(jorge, instrumentista(guitarra)).
puedeCumplir(daniel, instrumentista(guitarra)).
puedeCumplir(daniel, actor(narrador)).
puedeCumplir(daniel, instrumentista(tuba)).
puedeCumplir(daniel, actor(paciente)).
puedeCumplir(marcos, actor(narrador)).
puedeCumplir(marcos, actor(psicologo)).
puedeCumplir(marcos, instrumentista(percusion)).
puedeCumplir(daniel, instrumentista(percusion)).
puedeCumplir(carlos, instrumentista(violin)).
puedeCumplir(carlitos, instrumentista(piano)).
puedeCumplir(daniel, actor(canto)).
puedeCumplir(carlos, actor(canto)).
puedeCumplir(carlitos, actor(canto)).
puedeCumplir(marcos, actor(canto)).
puedeCumplir(jorge, actor(canto)).
puedeCumplir(jorge, instrumentista(bolarmonio)).

% necesita(Sketch, Rol): relaciona un sketch con un rol necesario para interpretarlo.
necesita(payadaDeLaVaca, instrumentista(guitarra)).
necesita(malPuntuado, actor(narrador)).
necesita(laBellaYGraciosaMozaMarchoseALavarLaRopa, actor(canto)).
necesita(laBellaYGraciosaMozaMarchoseALavarLaRopa, instrumentista(violin)).
necesita(laBellaYGraciosaMozaMarchoseALavarLaRopa, instrumentista(tuba)).
necesita(lutherapia, actor(paciente)).
necesita(lutherapia, actor(psicologo)).
necesita(cantataDelAdelantadoDonRodrigoDiazDeCarreras, actor(narrador)).
necesita(cantataDelAdelantadoDonRodrigoDiazDeCarreras, instrumentista(percusion)).
necesita(cantataDelAdelantadoDonRodrigoDiazDeCarreras, actor(canto)).
necesita(rhapsodyInBalls, instrumentista(bolarmonio)).
necesita(rhapsodyInBalls, instrumentista(piano)).

% duracion(Sketch, Duracion):. relaciona un sketch con la duración (aproximada, pero la vamos a tomar como fija) que se necesita para interpretarlo.
duracion(payadaDeLaVaca, 9).
duracion(malPuntuado, 6).
duracion(laBellaYGraciosaMozaMarchoseALavarLaRopa, 8).
duracion(lutherapia, 15).
duracion(cantataDelAdelantadoDonRodrigoDiazDeCarreras, 17).
duracion(rhapsodyInBalls, 7).

% 1
interprete(Persona, Sketch):-
    necesita(Sketch, Rol),
    puedeCumplir(Persona, Rol).

% 2
duracionTotal(Show, DuracionTotal):-
    maplist(duracion, Show, Duraciones),
    %findall(Duracion, (member(Sketch, Show), duracion(Sketch, Duracion)), Duraciones),
    sum_list(Duraciones, DuracionTotal).

% 3
puedeSerInterpretado(Sketch, Interpretes):-
    sketch(Sketch),
    forall(necesita(Sketch, Requerimiento), 
          (member(Interprete, Interpretes), puedeCumplir(Interprete, Requerimiento))).
    
sketch(Sketch):-
    distinct(Sketch, necesita(Sketch, _ )).
    %duracion(Sketch, _).

% 4
/*
generarShow(Interpretes, DuracionMaxima, [Sketch]):-
    puedeSerInterpretado(Sketch, Interpretes),
    duracion(Sketch, Duracion),
    Duracion < DuracionMaxima.
generarShow(Interpretes, DuracionMaxima, [Sketch | Sketches]):-
    puedeSerInterpretado(Sketch, Interpretes),
    not(member(Sketch, Sketches)),
    DuracionMaxima >= Duracion,
    duracion(Sketch, Duracion),
    DuracionRestante is DuracionMaxima - Duracion,
    generarShow(Interpretes, DuracionRestante, Sketches).
*/
generarShow(Interpretes, DuracionMaxima, Show):-
    sketchesPosibles(Interpretes, Sketches),
    subconjunto(Sketches, Show),
    duracionTotal(Show, Duracion),
    Duracion =< DuracionMaxima,
    Show \= [].

subconjunto(_, []).
subconjunto(Conjunto, [Elemento|OtrosElementos]):-
    select(Elemento, Conjunto, RestoConjunto),
    subconjunto(RestoConjunto, OtrosElementos).

sketchesPosibles(Interpretes, Sketches):-
    findall(Sketch, puedeSerInterpretado(Sketch, Interpretes), Sketches).

/* Como segunda opción se plantea no trabajar primero con subconjuntos y luego con el total, 
sino hacerlo armando la lista en base a sketches para los cuales alcance el tiempo restante,
en forma recursiva partiendo de la lista vacía.*/

% 5
estrella(Show, Estrella):-
    interprete(Estrella),
    forall(member(Sketch, Show), interprete(Estrella, Sketch)).

interprete(Interprete):-
    distinct(Interprete, puedeCumplir(Interprete, _ )).

% 6.a
puramenteMusical(Show):-
    forall(member(Sketch, Show), esMusical(Sketch)).

esMusical(Sketch):-
    forall(necesita(Sketch, Rol), instrumentista(Rol)).

instrumentista(instrumentista(_)).

% 6.b
todosCortitos(Show):-
    forall(member(Sketch, Show), esCorto(Sketch)).

esCorto(Sketch):-
    duracion(Sketch, Duracion),
    Duracion < 10.

% 6.c
juntaATodos(Show):-
    forall(interprete(Interprete), esNecesario(Interprete, Show)).

/**
 * interprete/2 
 * Un intérprete es necesario cuando hay algún Sketch del Show para el cual no hay otro
 * intérprete posible (para algún rol, sólo existe ese intérprete, no hay otro).
 */
esNecesario(Interprete, Show):-
    member(Sketch, Show),
    necesita(Sketch, Rol),
    puedeCumplir(Interprete, Rol),
    not((puedeCumplir(OtroInterprete, Rol), Interprete \= OtroInterprete)).
% Autor: Edwin Manuel Cerron Angeles
% Fecha: 01/11/2011

% Horario_biblioteca.PL
horario :-
            findall(vacante(Dia,Tiempo,Trabajo,Numero),
            vacante(Dia,Tiempo,Trabajo,Numero),Vacantes),
            horario_aux(Vacantes,[],HorarioIntermedio),
            horario_mejorado(HorarioIntermedio,Horario),
            escribir_reporte(Horario).
%
%
%
horario_aux([],Horario,Horario).
horario_aux([vacante(_,_,_,0)|RestoDeVacantes],Parcial,Horario):-
            horario_aux(RestoDeVacantes,Parcial,Horario).
%
% disponible(+Dia,+Tiempo,+Trabajo,-Persona,+Parcial)
% encuentra a una persona disponible en el horario parcial en el cual pueda asignarse en el turno y dia.
%
disponible(Dia,Tiempo,Trabajo,Persona,Parcial) :-
            trabajo(Trabajo,ListaTrabajo),
            member(Persona,ListaTrabajo),
            \+ member(sched(Dia,Tiempo,_,Persona),Parcial),
            personal(Persona,MinimoSemana,_,PorDia,Dias),
            member(Dia,Dias),
            findall(T,member(sched(Dia,T,J,Persona),Parcial),ListaDia),
            length(ListaDia,D),
            D<PorDia,
            findall(T,member(sched(D,T,J,Persona),Parcial),ListaSemana),
            length(ListaSemana,W),
            W<MinimoSemana.
            
disponible(Dia,Tiempo,Trabajo,Persona,Parcial) :-
            trabajo(Trabajo,ListaTrabajo),
            member(Persona,ListaTrabajo),
            \+ member(sched(Dia,Tiempo,_,Persona),Parcial),
            personal(Persona,_,MaximoSemanal,PorDia,Dias),
            member(Dia,Dias),
            findall(T,member(sched(Dia,T,J,Persona),Parcial),ListaDia),
            length(ListaDia,D),
            D<PorDia,
            findall(T,member(sched(D,T,J,Persona),Parcial),ListaSemana),
            length(ListaSemana,W),
            W<MaximoSemanal.
%
% horario_mejorado(+Actual,-Despues)
% Reemplaza el actual horaio con otro mejorado, reasigna la vacante segun las necesidades de turnos.
% elimina los turnos extras, asignando estos a las personas que no tienen sus turnos minimos.
%
horario_mejorado(Horario,Horario) :-
            \+ necesidades_de_turnos(_,Horario).
horario_mejorado(Actual,Horario) :-
            necesidades_de_turnos(Person1,Actual),
            tiene_turno_extra(Person2,Actual),
            personal(Person1,_,_,PorDia,Dias),
            member(sched(Dia,Tiempo,Trabajo,Person2),Actual),
            member(Dia,Dias),
            \+ member(sched(Dia,Tiempo,_,Person1),Actual),
            trabajo(Trabajo,ListaTrabajo),
            member(Person1,ListaTrabajo),
            findall(T,member(sched(Dia,T,J,Person1),Actual),ListaDia),         %J es singleton              length(ListaDia,D),
            D < PorDia,
            !,
            write('Reorganizando:'),
            reporte(Dia,Tiempo,Trabajo,Person2),
            remove(sched(Dia,Tiempo,Trabajo,Person2),Actual,Parcial),
            horario_mejorado([sched(Dia,Tiempo,Trabajo,Person1)|Parcial],Horario).
horario_mejorado(Horario,Horario).

%
%  Predicados para encontrar a personas que tienen menos o más turnos de trabajos, que el establecido para el horario.
%  D J  variables singleton = reemplazar por una variable anonima.
necesidades_de_turnos(Persona,Horario) :-
              personal(Persona,MinimoSemana,_,_,_),
              findall(T,member(sched(D,T,J,Persona),Horario),Turnos),
              length(Turnos,S),
              S < MinimoSemana.
tiene_turno_extra(Persona,Horario):-
              personal(Persona,MinimoSemana,_,_,_),
              findall(T,member(sched(D,T,J,Persona),Horario),Turnos),
              length(Turnos,S),
              S > MinimoSemana.
remove(X,[X|Y],Y):-!.
remove(X,[Y|Z],[Y|W]):-remove(X,Z,W).

member(X,[X|_]).
member(X,[_|Y]):-member(X,Y).
%
% Predicado para mostrar el Horario
%
escribir_reporte(Horario) :-
              nl,nl,
              write('Horario para la semana:'),nl,nl,
              member(Dia,[lunes,martes,miercoles,jueves,viernes]),
              findall(sched(Dia,Tiempo,Trabajo,Persona),
              member(sched(Dia,Tiempo,Trabajo,Persona),Horario),
              DaySchedule),
              reporte_lista1(DaySchedule),nl,
              write('Presione Enter para continuar.'),get0(_),nl,nl,
              Dia=viernes,
              findall(person(Persona,Min,Max),
              personal(Persona,Min,Max,_,_),PersonList),
              reporte_lista2(PersonList,Horario),
              !.
reporte_lista1([]).
reporte_lista1([sched(Dia,Tiempo,Trabajo,Persona)|RestOfSchedule]):-
              reporte(Dia,Tiempo,Trabajo,Persona),
              reporte_lista1(RestOfSchedule).
reporte(Dia,Tiempo,Trabajo,Persona) :-
              write(Dia),write(' '),write(Tiempo),write(' '),
              write(Trabajo),write(' '),write(Persona),nl.
reporte_lista2([],_):- write('Fin del Reporte.'),nl,nl.
reporte_lista2([person(Persona,Min,Max)|Rest],Horario) :-
              write(Persona),write('''s horario('),
              write(Min),write(' a '),
              write(Max),write(' turnos por semana):'),nl,nl,
              member(Dia,[lunes,martes,miercoles,jueves,viernes]),
              findall(sched(Dia,Tiempo,Trabajo,Persona),
              member(sched(Dia,Tiempo,Trabajo,Persona),Horario),DaySchedule),
              reporte_lista2_auxiliar(DaySchedule),
              Dia=viernes,nl,
              write('Presione una tecla para continuar.'),get0(_),nl,nl,
              reporte_lista2(Rest,Horario).
reporte_lista2_auxiliar([]).
reporte_lista2_auxiliar([sched(Dia,Tiempo,Trabajo,_)|Rest]) :-
              reporte(Dia,Tiempo,Trabajo,''),
              reporte_lista2_auxiliar(Rest).
%
% Datos del Horario
%
vacante(lunes,am,catalogador,1).
vacante(lunes,am,recepcionista,1).
vacante(lunes,pm,recepcionista,1).
vacante(lunes,am,estantero,2).
vacante(lunes,pm,estantero,2).
vacante(martes,am,catalogador,1).
vacante(martes,am,recepcionista,1).
vacante(martes,pm,recepcionista,1).
vacante(martes,am,estantero,2).
vacante(martes,pm,estantero,2).
vacante(miercoles,am,catalogador,1).
vacante(miercoles,am,recepcionista,1).
vacante(miercoles,pm,recepcionista,1).
vacante(miercoles,am,estantero,2).
vacante(miercoles,pm,estantero,2).
vacante(jueves,am,catalogador,1).
vacante(jueves,am,recepcionista,1).
vacante(jueves,pm,recepcionista,1).
vacante(jueves,am,estantero,2).
vacante(jueves,pm,estantero,2).
vacante(viernes,am,catalogador,1).
vacante(viernes,am,recepcionista,1).
vacante(viernes,pm,recepcionista,1).
vacante(viernes,am,estantero,2).
vacante(viernes,pm,estantero,2).
personal(alicia,6,8,2,[lunes,martes,jueves,viernes]).
personal(pedro,7,10,2,[lunes,martes,miercoles,jueves,viernes]).
personal(carolina,3,5,1,[lunes,martes,miercoles,jueves,viernes]).
personal(juan,6,8,2,[lunes,martes,miercoles]).
personal(maria,0,2,1,[jueves,viernes]).
personal(manuel,7,10,2,[lunes,martes,miercoles,jueves,viernes]).

trabajo(catalogador,[alicia,manuel]).
trabajo(recepcionista,[pedro,carolina,manuel]).
trabajo(estantero,[alicia,pedro,carolina,juan,maria,manuel]).

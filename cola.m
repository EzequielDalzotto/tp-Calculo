function cola(p)
% p.modelo a =1 ,b=2, c=3, d=4
% p.LS duracion de la simulacion

% Seleccion del ejercicio.
switch p.modelo
    case 1
        % TODO (a): finite queue and rejected arrivals.
        warning('cola:PendingModel', 'Model 1 is pending. Running the original single-server queue.');
    case 2
        % TODO (b): two parallel servers.
        warning('cola:PendingModel', 'Model 2 is pending.');
        return;
    case 3
        % TODO (c): two queues and one server.
        warning('cola:PendingModel', 'Model 3 is pending.');
        return;
    case 4
        % TODO (d): abandonment after waiting.
        warning('cola:PendingModel', 'Model 4 is pending.');
        return;
end

% cola simple - 1 servidor - (VERSION MATLAB)
% (Tiempo Uniforme Entre Arribos y de Servicio)
% CAPACIDAD MAXIMA DE LA COLA = 200 ENTIDADES 
%
%  DEFINICION DE VARIABLES:
%
% ALQ          Longitud media de la cola
% ASULTIL      Utilizacion media del Servidor
% ATTRIB(I)    Atributo (tiempo de arribo) de la entidad I a la cola
% BUSY         variable binaria (0,1) que representa el estado del servidor
% CLQ          Longitud acumulada de la cola
% CSUTIL       Utilizacion acumulada del servidor
% LQ           Longitud actual de la cola
% LS           Longitud de simulacion en unidades de tiempo
% MINIAT       Tiempo minimo entre arribos
% MAXIAT       Tiempo Maximo entre arribos
% MINST        Tiempo Minimo de Servicio
% MAXST        Tiempo Maximo de Sevicio
% NEE          Numero Total de Entidades que entran en el Sistema
% NES          Numero Total de Entidades Servidas
% QLIMIT       Capacidad Maxima de la Cola
% TLE          Tiempo del último evento
% TNA          Tiempo del proximo arribo
% TND          Tiempo de la proxima partida
% TNOW         Tiempo actual de la Simulacion (Master Clock)
% TQT          Tiempo Total en la Cola

%corte         Bandera de corte de la simulacion para cuando se cumpla
%              el tiempo solicitado

%********************     INICIALIZACION      *********************
QLIMIT = 200;
ATTRIB = zeros(QLIMIT,1);
BUSY = 0; LQ = 0; NEE = 0; NES = 0; CLQ = 0; CSUTIL = 0; TQT = 0; TNOW = 0;
%
%  Programa el primer arribo en el tiempo 0. Fija el tiempo de la proxima
%  partida en un numero grande
%
TNA = 0;
TND = 99999;
%
%*********************** ENTRADA DE DATOS ************************
LS = p.LS;
MINIAT = 1;
MAXIAT = 3;
MINST = 1;
MAXST = 2;
%
%*********************** (MOTOR DE LA SIMULACION)   ****
%
%
%   Fija el Tiempo del Ultimo Evento (TLE) igual a TNOW antes de avanzar TNOW
%   hasta el Tiempo del Proximo evento (TNE)
%
%
%   Busca cual es el minimo tiempo para la proxima partida del servidor
%   Compara los tiempos de los dos eventos posibles siguientes
%   y fija TNOW igual al tiempo menor. Llama a la rutina de eventos asociada
%   Si TNOW excede la longitud de simulacion retorna a PRINCIPAL
%
%
    
  corte=0;
  
  while corte==0
    
    TLE = TNOW; 
      
    if (TNA < TND)
       
        TNOW = TNA;
        if (TNOW >= LS)
            %**************** ACTIVA LA BANDERA DE CORTE Y LLAMA A LA
            %FUNCION DE SALIDA PARA MOSTRAR LOS RESULTADOS *************
            corte=1;
            OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ); 
        else
            %********************* EVENTOS DE LLEGADA*********************
            %
            [NEE, TNA, BUSY, LQ, ATTRIB, TND]=ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND);
                     
        end
  
    else
        
        TNOW = TND;
        
        if (TNOW >= LS)
            %**************** ACTIVA LA BANDERA DE CORTE Y LLAMA A LA
            %FUNCION DE SALIDA PARA MOSTRAR LOS RESULTADOS *************
            corte=1;
            OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ); 
        else
            %******************** EVENTOS DE PARTIDA *******************
            %
            [NES, TQT, BUSY, LQ, ATTRIB, TND]=DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY);
            
            
        end
    end
        %****************** Llama la funcion STAT para actualizar las estadisticas de base tiempo ******************
        %
        
        [CLQ, CSUTIL]=STAT(CLQ, LQ, TNOW,TLE, CSUTIL, BUSY);
                   
  end
end

function [NEE, TNA, BUSY, LQ, ATTRIB, TND] = ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND)
%********************* FUNCION EVENTOS DE LLEGADA*********************
%
%   Incrementa el numero total de Entidades que Entran en el sistema.
%
NEE = NEE+1;
%
%   Programa el proximo arribo
%
TNA = TNOW+MINIAT+(MAXIAT - MINIAT)*rand(1);
%
%
%   Si el servidor esta ocupado se incrementa la longitud de la Cola
%   Si el tamano de la Cola excede el limite, se
%   imprime un mensaje de error y se detiene la ejecucion.
%   Si no se excede QLIMIT se fija el atributo de la entidad que arriba
%   igual a su tiempo de arribo. Retorno a la rutina de eventos.
%

if (BUSY == 1) 
   LQ = LQ + 1;
   if (LQ > QLIMIT) 
       disp(' Error - Overflow en la Cola! (LQ>100)')
       ATTRIB(LQ) = TNOW;
         
   end
   
   TND=TND;
     
else
%
%   Si se encontro el servidor desocupado, se lo ocupa (BUSY=1)
%   Se asigna la Entidad recien arribada al servidor desocupado.
%   Se calcula el tiempo de Servicio (TS) para la entidad.
%   Se programa el tiempo de partida para la Entidad.
%
    BUSY = 1;
    TS = MINST + (MAXST - MINST) * rand(1);
    TS = fix(TS * 100)/100;
    TND = TNOW + TS;
   
end
end

function [NES, TQT, BUSY, LQ, ATTRIB, TND]=DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY)
%******************** FUNCION EVENTOS DE PARTIDA *******************
%
%   Se Incrementa el Numero total de Entidades Servidas
%
NES = NES + 1;
%
%   Si la cola esta vacia se pone el Servidor
%   en disponibilidad (BUSY=0).
%   La proxima partida puede no estar programada por lo que se hace
%   TND igual a un numero grande.
%
if (LQ == 0) 
    BUSY = 0; TND = 99999; 
    
else
%
%   Si la cola no esta vacia, se calcula el tiempo de espera en la cola
%   para la entidad que comienza su servicio.
%   Se calcula el tiempo total en la Cola y se decrementa la longitud de
%   la misma.
%
    BUSY=BUSY;
    QT = TNOW - ATTRIB(1);
    TQT = TQT + QT;
    LQ = LQ - 1;
%
%   Se desplaza los valores de los atributos una posicion, a medida que la
%   cola 1 se desplaza hacia adelante.
%
    for i=1:LQ
        ATTRIB(i)=ATTRIB(i+1);
        i=i+1;
    end
%
%   Se programa el tiempo de partida para la entidad que comenzo a ser
%   atendida y se vuelve a la rutina de eventos.
%
    TS = MINST + (MAXST - MINST) * rand(1);
    TS = floor(TS * 100)/100;
    TND = TNOW+TS;
end
end

function [CLQ, CSUTIL]=STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY)
%****************** FUNCION DE ESTADISTICAS BASE TIEMPO ******************
%
%
%   Calcula la longitud acumulada de la Cola y la Utilizacion del Servidor
%   actualizando los valores que tenian en el ultimo evento.
%

CLQ = CLQ+LQ*(TNOW - TLE);
CSUTIL=CSUTIL+BUSY*(TNOW-TLE);
end

function OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ)
%************************* FUNCION DE SALIDA  **************************
%
%
%   Calcula el tiempo medio de espera en la Cola (AWTQ) como
%   Estadistico de base observacion.
%
AWTQ = TQT/NES;
%
%   Calcula los promedios ponderados de los estadisticos de base tiempo
%   e imprime los resultados
%
ALQ = CLQ/TNOW;
%
ASUTIL = CSUTIL/TNOW;
%
fprintf('\n');
fprintf('Salida de la SIMULACION: ');
fprintf('\n');
fprintf('Numero de Entidades Entradas= %2.0d', NEE);
fprintf('\n');
fprintf('Numero de Entidades Servidas= %2.0d', NES);
fprintf('\n');
fprintf('LQ= %2.0d', LQ);
fprintf('\n');
fprintf('TNOW= %2.3f', TNOW);
fprintf('\n');
fprintf('CSUTIL= %2.3f', CSUTIL);
fprintf('\n');
fprintf('Tiempo Total Perdido en la Cola= %2.3f', TQT);
fprintf('\n');
fprintf('Promedio de tiempo de espera en la Cola= %2.3f', AWTQ);
fprintf('\n');
fprintf('Longitud Promedio (esperada) de la Cola= %2.3f', ALQ);
fprintf('\n');
PRO=ASUTIL*100;
fprintf('Promedio de Uso del Servidor= %2.3f', PRO);
end

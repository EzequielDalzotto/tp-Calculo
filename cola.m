function cola(p)
% p.modelo a =1 ,b=2, c=3, d=4
% p.LS duracion de la simulacion

% Seleccion del ejercicio.
switch p.modelo
    case 1
        % Modelo 1 hecho
    case 2
        % Modelo 2 hecho
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
tiemposRechazo = []; %vector para ejercicio a

% Ejercicio a
if p.modelo == 1
    QLIMIT = 10;
end
ATTRIB = zeros(QLIMIT,1);
BUSY = 0; LQ = 0; NEE = 0; NES = 0; CLQ = 0; CSUTIL = 0; TQT = 0; TNOW = 0;
BUSY2 = 0; CSUTIL2 = 0; TND2 = 0;
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
    if p.modelo == 2
        LQAnterior = LQ;
        BUSYAnterior = BUSY;
        BUSY2Anterior = BUSY2;
    end
      
    if (TNA < TND || (p.modelo == 2 && BUSY == 0)) && ...
            (p.modelo ~= 2 || BUSY2 == 0 || TNA < TND2)
       
        TNOW = TNA;
        if (TNOW >= LS)
            %**************** ACTIVA LA BANDERA DE CORTE Y LLAMA A LA
            %FUNCION DE SALIDA PARA MOSTRAR LOS RESULTADOS *************
            corte=1;
        else
            %********************* EVENTOS DE LLEGADA*********************
            %
            [NEE, TNA, BUSY, LQ, ATTRIB, TND, tiemposRechazo, BUSY2, TND2] = ...
                ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND, p.modelo, tiemposRechazo, BUSY2, TND2);
                     
        end
  
    elseif p.modelo ~= 2 || BUSY2 == 0 || (BUSY == 1 && TND <= TND2)
        
        TNOW = TND;
        
        if (TNOW >= LS)
            %**************** ACTIVA LA BANDERA DE CORTE Y LLAMA A LA
            %FUNCION DE SALIDA PARA MOSTRAR LOS RESULTADOS *************
            corte=1;
        else
            %******************** EVENTOS DE PARTIDA *******************
            %
            [NES, TQT, BUSY, LQ, ATTRIB, TND]=DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY);
            
            
        end
    else % Proximo evento: partida del servidor 2
        TNOW = TND2;
        if (TNOW >= LS)
            corte=1;
        else
            [NES, TQT, BUSY2, LQ, ATTRIB, TND2]=DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY2);
        end
    end
        %****************** Llama la funcion STAT para actualizar las estadisticas de base tiempo ******************
        %
        
    if p.modelo == 2
        TNOW = min(TNOW, LS);
        [CLQ, CSUTIL, CSUTIL2] = STAT(CLQ, LQAnterior, TNOW, TLE, CSUTIL, BUSYAnterior, p.modelo, CSUTIL2, BUSY2Anterior);
    elseif ~corte
        [CLQ, CSUTIL] = STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY, p.modelo, CSUTIL2, BUSY2);
    end
                   
  end
  OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ, p.modelo, tiemposRechazo, CSUTIL2);
end

function [NEE, TNA, BUSY, LQ, ATTRIB, TND, tiemposRechazo, BUSY2, TND2] = ...
    ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND, modelo, tiemposRechazo, BUSY2, TND2)
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

if modelo == 2% Ejercicio b.

    if BUSY == 0
        % Ocupar servidor 1
        BUSY = 1;
        TS = MINST + (MAXST - MINST) * rand(1);
        TS = fix(TS * 100) / 100;
        TND = TNOW + TS;

    elseif BUSY2 == 0
        % Ocupar servidor 2
        BUSY2 = 1;
        TS = MINST + (MAXST - MINST) * rand(1);
        TS = fix(TS * 100) / 100;
        TND2 = TNOW + TS;
    else
        % Ambos servidores ocupados: ingresar a la cola
        LQ = LQ + 1;
        ATTRIB(LQ) = TNOW;

        if (LQ > QLIMIT)
            disp(' Error - Overflow en la Cola! (LQ>100)')
            ATTRIB(LQ) = TNOW;
        end

    end

else 
if (BUSY == 1)

    switch modelo
        case 1% Ejercicio a.

            if (LQ >= QLIMIT)
                disp(' Error - Overflow en la Cola! (LQ>10) (Modelo a)')
                tiemposRechazo = [tiemposRechazo, TNOW]; % Tiempo de rechazo y posicion = cantidad de rechazos
            else
                LQ = LQ + 1;
                ATTRIB(LQ) = TNOW;
            end

        otherwise
            LQ = LQ + 1;

            if (LQ > QLIMIT)
                disp(' Error - Overflow en la Cola! (LQ>100)')
                ATTRIB(LQ) = TNOW;
            end

            TND = TND;
    end

else
    %
    %   Si se encontro el servidor desocupado, se lo ocupa (BUSY=1)
    %   Se asigna la Entidad recien arribada al servidor desocupado.
    %   Se calcula el tiempo de Servicio (TS) para la entidad.
    %   Se programa el tiempo de partida para la Entidad.
    %
    BUSY = 1;
    TS = MINST + (MAXST - MINST) * rand(1);
    TS = fix(TS * 100) / 100;
    TND = TNOW + TS;

end
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

function [CLQ, CSUTIL, CSUTIL2]=STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY, modelo, CSUTIL2, BUSY2)
%****************** FUNCION DE ESTADISTICAS BASE TIEMPO ******************
%
%
%   Calcula la longitud acumulada de la Cola y la Utilizacion del Servidor
%   actualizando los valores que tenian en el ultimo evento.
%

CLQ = CLQ+LQ*(TNOW - TLE);
CSUTIL=CSUTIL+BUSY*(TNOW-TLE);
if modelo == 2
    CSUTIL2=CSUTIL2+BUSY2*(TNOW-TLE);
end
end

function OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ, modelo, tiemposRechazo, CSUTIL2)
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

switch modelo
    case 1
        fprintf('Tiempos de rechazo: %s\n', mat2str(tiemposRechazo)) % para comprobar
        fprintf('Cantidad de rechazos: %d\n', length(tiemposRechazo));
        if numel(tiemposRechazo) >= 2
            fprintf('Tiempo medio entre rechazos: %.2f\n', mean(diff(tiemposRechazo)));
        else
            fprintf('Tiempo medio entre rechazos: sin datos suficientes\n');
        end
end

PRO=ASUTIL*100;
fprintf('Promedio de Uso del Servidor 1= %2.3f', PRO);
if modelo == 2
    ASUTIL2 = CSUTIL2/TNOW;
    PRO2 = ASUTIL2*100;
    fprintf('\nPromedio de Uso del Servidor 2= %2.3f', PRO2);
end
end

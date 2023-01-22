
-- Crear una FA que, dado un período de tiempo (mes-año) permita retornar el total de puntos acumulados 
-- por los jugadores en el período indicado
-- Crear un SP que permita insertar un registro en la tabla summary_period, debe usar SQL DINÁMICO
-- Crear un SP que permita generar el resumen de puntos por período: el resultado debe quedar en la taabla SUMMARY_PERIOD

-- Mantener actualizada, ante cualquier cambio en la tabla player la tabla summary_period. Los cambios que debe contemplar
-- son INSERCIÓN DE UN NUEVO JUGADOR Y LA ACTUALIZACIÓN DE LA FECHA DEL JUEGO

-- Construir la FA
CREATE OR REPLACE FUNCTION fn_puntos_acumulados(p_periodo VARCHAR2)
RETURN NUMBER
IS
    total_puntos NUMBER;
BEGIN
    SELECT NVL(SUM(points),0)
    INTO total_puntos
    FROM player
    WHERE TO_CHAR(date_play,'MM-YYYY') = p_periodo;

    RETURN total_puntos;
END;

-- Construir el SP
CREATE OR REPLACE PROCEDURE sp_insertar_registro(p_periodo VARCHAR2, p_puntos NUMBER)
IS
    s_query VARCHAR2(500);
BEGIN
    s_query := 'INSERT INTO summary_period VALUES(:1, :2)';    
    EXECUTE IMMEDIATE s_query USING p_periodo, p_puntos;
END;

-- Construir el segundo SP 
CREATE OR REPLACE PROCEDURE sp_generar_resumen
IS
    -- Almacena los distintos períodos a procesar
    CURSOR c_periodos IS
        SELECT DISTINCT TO_CHAR(date_play,'MM-YYYY') periodo
        FROM player
        ORDER BY 1;
    -- Almacena el total de puntos de un período
    total_p NUMBER;
BEGIN
    -- Procesar los periodos disponibles
    FOR reg_periodo IN c_periodos LOOP
        -- Obtener el total de puntos del período
        total_p := fn_puntos_acumulados(reg_periodo.periodo);
        -- Insertar los resultados en la tabla summary_period
        sp_insertar_registro(reg_periodo.periodo, total_p);
    END LOOP;
END;

-- Probar el SP principal
EXEC sp_generar_resumen;

SELECT * FROM summary_period;

-- Construir un trigger para mantener actualizada la tabla summary_period
CREATE OR REPLACE TRIGGER trg_player
AFTER INSERT OR UPDATE OF date_play ON player
FOR EACH ROW
DECLARE
    total_registros NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO total_registros
    FROM summary_period
    WHERE period = TO_CHAR(:NEW.date_play,'MM-YYYY');

    IF total_registros > 0 THEN
        -- Descontar los puntos del período antiguo
        UPDATE summary_period
        SET points = points - :OLD.points
        WHERE period = TO_CHAR(:OLD.date_play,'MM-YYYY');

        -- Agrega los puntos al nuevo periodo
        UPDATE summary_period
        SET points = points + :OLD.points
        WHERE period = TO_CHAR(:NEW.date_play,'MM-YYYY');
    ELSE

        INSERT INTO summary_period
        VALUES(TO_CHAR(:NEW.date_play,'MM-YYYY'), :NEW.points);
        IF UPDATING THEN
            UPDATE summary_period
            SET points = points - :NEW.points
            WHERE period = TO_CHAR(:OLD.date_play,'MM-YYYY');
        END IF;
    END IF;
END;


SELECT * FROM summary_period WHERE period = '09-2021';

INSERT INTO player
VALUES (seq_player.nextval, TO_DATE('12-09-2021','DD-MM-YYYY'),'Yoshi', 100);

SELECT * FROM player WHERE id_play = 1001;

SELECT * FROM summary_period WHERE period IN('08-2021', '09-2021');
SELECT * FROM player WHERE id_play = 1001;

UPDATE player
SET date_play = TO_DATE('12-08-2021','DD-MM-YYYY')
WHERE id_play = 1001;

SELECT * FROM player WHERE id_play = 542;

SELECT * FROM summary_period
WHERE period IN('10-2022', '09-2022');

UPDATE player
SET date_play = TO_DATE('13-09-2022','DD-MM-YYYY')
WHERE id_play = 542;




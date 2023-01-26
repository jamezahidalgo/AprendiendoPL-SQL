/*
Construir:

1) Un procedimiento almacenado que inserte un registro
en la tabla PLAYER

2) Una función almacenada que, dado el ID de un juego (id_play),
retorne el nick name asociado a ese juego
del jugador 
*/
CREATE OR REPLACE PROCEDURE sp_inserta_juego(p_nick VARCHAR2, p_fecha DATE,
p_puntos NUMBER)
IS
BEGIN
    INSERT INTO player
    VALUES(SEQ_PLAYER.NEXTVAL, p_fecha, p_nick, p_puntos);
END;

EXEC sp_inserta_juego('Mario Bros', TO_DATE('12-06-2022','DD-MM-YYYY'), 1900);

CREATE TABLE persona
(
    id_persona NUMBER PRIMARY KEY,
    nombre VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE sp_registra_persona(p_id NUMBER, p_nombre VARCHAR2)
IS
    msg_error VARCHAR2(100);
BEGIN
    INSERT INTO persona VALUES(p_id, p_nombre);
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    -- Acciones a ejecutar en caso del error
    msg_error := SQLERRM;
    DBMS_OUTPUT.PUT_LINE('Registro duplicado ' || msg_error);
END;

EXEC sp_registra_persona(1, 'Segismundo II');

CREATE OR REPLACE FUNCTION fn_obtener_nick(p_idplay NUMBER)
RETURN VARCHAR2
IS
    p_nombre player.nick_name%TYPE;
BEGIN
    BEGIN
        SELECT nick_name
        INTO p_nombre
        FROM player
        WHERE id_play = p_idplay;
        RETURN p_nombre;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 'SIN NOMBRE';
    END;
END;

-- Prueba de la función
SET SERVEROUTPUT ON;
DECLARE
    nick player.nick_name%TYPE;
BEGIN
    nick := fn_obtener_nick(29985);
    DBMS_OUTPUT.PUT_LINE(nick);
END;
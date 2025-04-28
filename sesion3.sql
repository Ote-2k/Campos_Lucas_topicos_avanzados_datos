DECLARE
	v_test NUMBER;
BEGIN
	--este calculo fue el primero que vi en un libro de matematicas de basica
	v_test := 1+2+3+4;

	--realmente a mi no se me ocurrio nada realmente grande o complicado segun la instruccion, asi que hice que los altos medios o bajos sean:
	--si esta por encima de 10, seria alto
	IF v_test > 10 THEN
		DBMS_OUTPUT.PUT_LINE('valor alto superior a 10 (' || v_test ' || ')');
	--si esta por debajo de 10, es bajo
	ELSIF v_test < 10 THEN
		DBMS_OUTPUT.PUT_LINE('valor bajo menor a 10 (' || v_test ' || ')');
	--si es 10 es medio
	ELSE
		DBMS_OUTPUT.PUT_LINE('el valor es 10 (' || v_test ' || ')');
	END IF;
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
END;
/
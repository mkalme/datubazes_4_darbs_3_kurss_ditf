SET TIMING ON;
BEGIN
  FOR i IN 1..100000 LOOP
    FOR r IN (
      SELECT j.*
FROM university_json,
     JSON_TABLE(
        json_data,
        '$.universitate.fakultate.studiju_programma.studiju_kurss[*].modulis[*]'
        COLUMNS (
            modula_nosaukums VARCHAR2(100) PATH '$.nosaukums',
            NESTED PATH '$.temats[*].apraksts'
            COLUMNS (apraksts VARCHAR2(200) PATH '$')
        )
     ) j
    ) LOOP
      NULL;
    END LOOP;
  END LOOP;
END;
/
SET TIMING OFF;
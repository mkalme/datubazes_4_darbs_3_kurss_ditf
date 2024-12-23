-- XMLTable vaicajumi

-- 1. Vaicajums: Iegust informaciju par visiem studiju kursiem un to moduliem
SELECT jt.*
FROM university_json,
     JSON_TABLE(
        json_data, '$.universitate.fakultate.studiju_programma.studiju_kurss[*]' 
        COLUMNS (
            kursa_nos VARCHAR2(100) PATH '$.nosaukums',
            NESTED PATH '$.modulis[*]' 
            COLUMNS (
                modula_nos VARCHAR2(100) PATH '$.nosaukums',
                NESTED PATH '$.temats[*]'
                COLUMNS (
                    temata_nos VARCHAR2(100) PATH '$.nosaukums',
                    apraksts VARCHAR2(200) PATH '$.apraksts',
                    krediti NUMBER PATH '$.kreditpunkti',
                    stundas NUMBER PATH '$.stundu_skaits'
                )
            )
        )
     ) jt;

-- 2. Vaicajums: Iegust kopsavilkumu par fakultati un tas programmam
SELECT 
    j.fakultates_nos,
    j.programmas_nos,
    COUNT(j.temata_nos) as tematu_skaits,
    SUM(j.krediti) as kopejie_krediti
FROM university_json,
     JSON_TABLE(
        json_data, 
        '$.universitate.fakultate'
        COLUMNS (
            fakultates_nos VARCHAR2(100) PATH '$.nosaukums',
            programmas_nos VARCHAR2(100) PATH '$.studiju_programma.nosaukums',
            NESTED PATH '$.studiju_programma.studiju_kurss[*].modulis[*].temats[*]'
            COLUMNS (
                temata_nos VARCHAR2(100) PATH '$.nosaukums',
                krediti NUMBER PATH '$.kreditpunkti'
            )
        )
     ) j
GROUP BY j.fakultates_nos, j.programmas_nos;


-- XMLQuery vaicajumi

-- 1. Vaicajums: Atrod visus tematus, kuriem ir vairak neka 1 kreditpunkts
SELECT j.*
FROM university_json,
     JSON_TABLE(
        json_data, 
        '$..temats[*]?(@.kreditpunkti > 1)'
        COLUMNS (
            nosaukums VARCHAR2(100) PATH '$.nosaukums',
            krediti NUMBER PATH '$.kreditpunkti',
            stundas NUMBER PATH '$.stundu_skaits'
        )
     ) j;

-- 2. Vaicajums: Atrod visus modulus un to kopejo kreditpunktu skaitu
SELECT 
    j.nosaukums,
    COUNT(j.kreditpunkti) as tematu_skaits,
    SUM(j.kreditpunkti) as kopejie_kreditpunkti
FROM university_json,
     JSON_TABLE(
        json_data,
        '$..modulis[*]'
        COLUMNS (
            nosaukums VARCHAR2(100) PATH '$.nosaukums',
            NESTED PATH '$.temats[*]'
            COLUMNS (
                kreditpunkti NUMBER PATH '$.kreditpunkti'
            )
        )
     ) j
GROUP BY j.nosaukums;


-- XMLCast vaicajumi

-- 1. Vaicajums: Iegust visu tematu nosaukumus un kreditpunktus, parversot tos konkretos datos tipos
SELECT j.*
FROM university_json,
     JSON_TABLE(
        json_data,
        '$.universitate.fakultate.studiju_programma.studiju_kurss[*].modulis[*].temats[*]'
        COLUMNS (
            temata_nosaukums VARCHAR2(100) PATH '$.nosaukums',
            kreditpunkti NUMBER PATH '$.kreditpunkti'
        )
     ) j;

-- 2. Vaicajums: Iegust modulu nosaukumus un to tematu aprakstus
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
     ) j;
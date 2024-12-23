-- XMLTable vaicajumi

-- 1. Vaicajums: Iegust informaciju par visiem studiju kursiem un to moduliem
SELECT k.kursa_nos,
       m.modula_nos,
       t.temata_nos,
       t.apraksts,
       t.krediti,
       t.stundas
FROM university_xml x,
     XMLTABLE(
        '/universitate/fakultate/studiju_programma/studiju_kurss'
        PASSING x.XML_DATA
        COLUMNS 
            kursa_nos VARCHAR2(100) PATH '@nosaukums',
            modulis XMLTYPE PATH 'modulis'
     ) k,
     XMLTABLE(
        'modulis'
        PASSING k.modulis
        COLUMNS 
            modula_nos VARCHAR2(100) PATH '@nosaukums',
            temati XMLTYPE PATH 'temats'
     ) m,
     XMLTABLE(
        'temats'
        PASSING m.temati
        COLUMNS 
            temata_nos VARCHAR2(100) PATH '@nosaukums',
            apraksts VARCHAR2(200) PATH 'apraksts',
            krediti NUMBER PATH 'kreditpunkti',
            stundas NUMBER PATH 'stundu_skaits'
     ) t;

-- 2. Vaicajums: Iegust kopsavilkumu par fakultati un tas programmam
SELECT f.fakultates_nos,
       p.programmas_nos,
       COUNT(t.temata_nos) as tematu_skaits,
       SUM(t.krediti) as kopejie_krediti
FROM university_xml x,
     XMLTABLE(
        '/universitate/fakultate'
        PASSING x.XML_DATA
        COLUMNS 
            fakultates_nos VARCHAR2(100) PATH '@nosaukums'
     ) f,
     XMLTABLE(
        '/universitate/fakultate/studiju_programma'
        PASSING x.XML_DATA
        COLUMNS 
            programmas_nos VARCHAR2(100) PATH '@nosaukums'
     ) p,
     XMLTABLE(
        '//temats'
        PASSING x.XML_DATA
        COLUMNS 
            temata_nos VARCHAR2(100) PATH '@nosaukums',
            krediti NUMBER PATH 'kreditpunkti'
     ) t
GROUP BY f.fakultates_nos, p.programmas_nos;


-- XMLQuery vaicajumi

-- 1. Vaicajums: Atrod visus tematus, kuriem ir vairak neka 1 kreditpunkts
SELECT x.*
FROM university_xml,
     XMLTABLE('//temats[kreditpunkti > 1]'
              PASSING XML_DATA
              COLUMNS 
                  nosaukums VARCHAR2(100) PATH '@nosaukums',
                  krediti NUMBER PATH 'kreditpunkti',
                  stundas NUMBER PATH 'stundu_skaits'
     ) x;

-- 2. Vaicajums: Atrod visus modulus un to kopejo kreditpunktu skaitu
SELECT x.*
FROM university_xml,
     XMLTABLE('//modulis'
              PASSING XML_DATA
              COLUMNS 
                  nosaukums VARCHAR2(100) PATH '@nosaukums',
                  kopejie_kreditpunkti NUMBER PATH 'sum(temats/kreditpunkti)',
                  tematu_skaits NUMBER PATH 'count(temats)'
     ) x;


-- XMLCast vaicajumi

-- 1. Vaicajums: Iegust visu tematu nosaukumus un kreditpunktus, parversot tos konkretos datos tipos
SELECT x.*
FROM university_xml,
     XMLTABLE('//temats'
              PASSING XML_DATA
              COLUMNS 
                  temata_nosaukums VARCHAR2(100) PATH '@nosaukums',
                  kreditpunkti NUMBER PATH 'kreditpunkti/text()'
     ) x;

-- 2. Vaicajums: Iegust modulu nosaukumus un to tematu aprakstus
SELECT x.*
FROM university_xml,
     XMLTABLE('//modulis'
              PASSING XML_DATA
              COLUMNS 
                  modula_nosaukums VARCHAR2(100) PATH '@nosaukums',
                  tematu_apraksti VARCHAR2(1000) PATH 'string-join(temats/apraksts, "; ")'
     ) x;
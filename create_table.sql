CREATE TABLE university_xml (
    id NUMBER PRIMARY KEY,
    xml_data XMLTYPE
);

CREATE TABLE university_json (
    id NUMBER PRIMARY KEY,
    json_data CLOB CHECK (json_data IS JSON)
);
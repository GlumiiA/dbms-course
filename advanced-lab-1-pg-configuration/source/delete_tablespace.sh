#!/bin/bash

echo "Удаление таблиц и данных"

psql -p 9476 -d fatredexam <<EOF
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
EOF

psql -p 9476 -d postgres <<EOF

REVOKE ALL ON TABLESPACE hit89 FROM labuser;
REVOKE ALL ON TABLESPACE tdg81 FROM labuser;
REVOKE ALL ON DATABASE fatredexam FROM labuser;

\c fatredexam
REVOKE ALL ON SCHEMA public FROM labuser;
REASSIGN OWNED BY labuser TO postgres;
DROP OWNED BY labuser CASCADE;
\c postgres

DROP DATABASE IF EXISTS fatredexam;
DROP TABLESPACE IF EXISTS hit89;
DROP TABLESPACE IF EXISTS tdg81;
DROP ROLE IF EXISTS labuser;

EOF
rm -rf ~/hit89
rm -rf ~/tdg81

echo "Очистка завершена"
#!/bin/bash

echo "Создание директорий tablespace..."
mkdir -p ~/hit89
mkdir -p ~/tdg81

chmod 700 ~/hit89
chmod 700 ~/tdg81

echo "Создание tablespace, базы и роли..."

psql -p 9476 -d postgres <<EOF

DROP TABLESPACE IF EXISTS hit89;
DROP TABLESPACE IF EXISTS tdg81;

CREATE TABLESPACE hit89 LOCATION '$HOME/hit89';
CREATE TABLESPACE tdg81 LOCATION '$HOME/tdg81';

DROP DATABASE IF EXISTS fatredexam;
CREATE DATABASE fatredexam TEMPLATE template1;

DROP ROLE IF EXISTS labuser;
CREATE ROLE labuser LOGIN PASSWORD 'labpass';

GRANT CONNECT ON DATABASE fatredexam TO labuser;
GRANT CREATE ON TABLESPACE hit89 TO labuser;
GRANT CREATE ON TABLESPACE tdg81 TO labuser;

EOF

echo "Настройка прав на схему public..."

psql -p 9476 -d fatredexam <<EOF

GRANT ALL ON SCHEMA public TO labuser;
GRANT CREATE ON SCHEMA public TO labuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO labuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO labuser;

EOF

echo "Создание таблиц и данных от имени labuser..."

psql -h localhost -p 9476 -d fatredexam -U labuser <<EOF

CREATE TEMPORARY TABLE sales (
    id SERIAL,
    amount INT
);

CREATE TEMPORARY TABLE customers (
    id SERIAL,
    name TEXT
);

CREATE TEMPORARY TABLE products (
    id SERIAL,
    name TEXT
);

INSERT INTO sales (amount) VALUES (100), (250), (500);
INSERT INTO customers (name) VALUES ('Ivan'), ('Anna'), ('Petr');
INSERT INTO products (name) VALUES ('Phone'), ('Laptop'), ('Tablet');

\echo ''
\echo 'Таблицы и их tablespace:'
SELECT tablename, tablespace
FROM pg_tables
WHERE schemaname = 'public';

EOF

echo "Готово"
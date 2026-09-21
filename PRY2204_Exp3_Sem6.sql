/* ============================================================================
   PRY2204 - Modelamiento de Bases de Datos
   Experiencia 3 - Semana 6
   Caso: Consultorio Medico Municipalidad Santa Gema
   
   ============================================================================ */


/* ============================================================================
   ============================================================================ */
BEGIN
   FOR t IN (
      SELECT table_name FROM (
         SELECT 'PAGO' AS table_name FROM dual UNION ALL
         SELECT 'DOSIS' FROM dual UNION ALL
         SELECT 'MEDICAMENTO' FROM dual UNION ALL
         SELECT 'RECETA' FROM dual UNION ALL
         SELECT 'PACIENTE' FROM dual UNION ALL
         SELECT 'MEDICO' FROM dual UNION ALL
         SELECT 'DIGITADOR' FROM dual UNION ALL
         SELECT 'BANCO' FROM dual UNION ALL
         SELECT 'DIAGNOSTICO' FROM dual UNION ALL
         SELECT 'COMUNA' FROM dual UNION ALL
         SELECT 'ESPECIALIDAD' FROM dual
      )
   ) LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
      EXCEPTION
         WHEN OTHERS THEN
               RAISE;
            END IF;
      END;
   END LOOP;
END;
/


/* ============================================================================
   ============================================================================ */

-- Tabla ESPECIALIDAD (normalizada, con identificador autoincremental)
CREATE TABLE especialidad (
    id_especialidad NUMBER GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1),
    nombre          VARCHAR2(50) NOT NULL
);

-- Tabla COMUNA (normalizada, identificador comienza en 1101 e incrementa de 1 en 1)
CREATE TABLE comuna (
    id_comuna NUMBER GENERATED AS IDENTITY (START WITH 1101 INCREMENT BY 1),
    nombre    VARCHAR2(50) NOT NULL
);

-- Tabla DIAGNOSTICO
CREATE TABLE diagnostico (
    cod_diagnostico NUMBER(3)    NOT NULL,
    nombre          VARCHAR2(25) NOT NULL
);

-- Tabla BANCO
CREATE TABLE banco (
    cod_banco NUMBER(2)    NOT NULL,
    nombre    VARCHAR2(25) NOT NULL
);

-- Tabla DIGITADOR (se agrega dv_digitador, exigido por la regla del digito verificador)
CREATE TABLE digitador (
    id_digitador  NUMBER(20)   NOT NULL,
    dv_digitador  CHAR(1)      NOT NULL,
    pnombre       VARCHAR2(25) NOT NULL,
    papellido     VARCHAR2(25) NOT NULL
);

-- Tabla MEDICO (especialidad pasa a ser FK; se agrega telefono, exigido por reglas de negocio)
CREATE TABLE medico (
    rut_med         NUMBER(8)    NOT NULL,
    dv_med          CHAR(1)      NOT NULL,
    pnombre         VARCHAR2(25) NOT NULL,
    snombre         VARCHAR2(25),
    papellido       VARCHAR2(25) NOT NULL,
    sapellido       VARCHAR2(25),
    id_especialidad NUMBER       NOT NULL,
    telefono        NUMBER(11)   NOT NULL
);

-- Tabla PACIENTE (comuna pasa a ser FK a la tabla normalizada COMUNA)
CREATE TABLE paciente (
    rut_pac     NUMBER(8)    NOT NULL,
    dv_pac      CHAR(1)      NOT NULL,
    pnombre     VARCHAR2(25) NOT NULL,
    snombre     VARCHAR2(25),
    edad        NUMBER(3),
    telefono    NUMBER(11),
    calle       VARCHAR2(25),
    numeracion  NUMBER(5),
    id_comuna   NUMBER       NOT NULL,
    ciudad      NUMBER(5),
    region      NUMBER(5)
);

-- Tabla RECETA (fecha_vencimiento corregida a DATE; tipo_receta acotado por CHECK)
CREATE TABLE receta (
    cod_receta         NUMBER(7)     NOT NULL,
    observaciones      VARCHAR2(500),
    fecha_emision      DATE          NOT NULL,
    fecha_vencimiento  DATE,
    id_digitador       NUMBER(20)    NOT NULL,
    pac_rut            NUMBER(8)     NOT NULL,
    id_diagnostico     NUMBER(3)     NOT NULL,
    med_rut            NUMBER(8)     NOT NULL,
    tipo_receta        VARCHAR2(15)  NOT NULL
);

-- Tabla MEDICAMENTO (se agregan dosis_recomendada y stock, exigidos por reglas de negocio)
CREATE TABLE medicamento (
    cod_medicamento    NUMBER(7)    NOT NULL,
    nombre             VARCHAR2(25) NOT NULL,
    tipo_medicamento   VARCHAR2(20) NOT NULL,
    via_administra     NUMBER(3),
    dosis_recomendada  VARCHAR2(25) NOT NULL,
    stock              NUMBER(6)    DEFAULT 0 NOT NULL
);

-- Tabla DOSIS (detalle de medicamentos por receta - relacion M:N)
CREATE TABLE dosis (
    id_medicamento     NUMBER(7)    NOT NULL,
    id_receta          NUMBER(7)    NOT NULL,
    descripcion_dosis  VARCHAR2(25)
);

-- Tabla PAGO (monto_total corregido a NUMBER)
CREATE TABLE pago (
    cod_boleta    NUMBER(6)    NOT NULL,
    id_receta     NUMBER(7)    NOT NULL,
    fecha_pago    DATE         NOT NULL,
    monto_total   NUMBER(9)    NOT NULL,
    metodo_pago   VARCHAR2(15),
    id_banco      NUMBER(2)
);


/* ============================================================================
   CASO 1: LLAVES PRIMARIAS (PRIMARY KEY)
   ============================================================================ */
ALTER TABLE especialidad ADD CONSTRAINT especialidad_pk PRIMARY KEY (id_especialidad);
ALTER TABLE comuna       ADD CONSTRAINT comuna_pk       PRIMARY KEY (id_comuna);
ALTER TABLE diagnostico  ADD CONSTRAINT diagnostico_pk  PRIMARY KEY (cod_diagnostico);
ALTER TABLE banco        ADD CONSTRAINT banco_pk        PRIMARY KEY (cod_banco);
ALTER TABLE digitador    ADD CONSTRAINT digitador_pk    PRIMARY KEY (id_digitador);
ALTER TABLE medico       ADD CONSTRAINT medico_pk       PRIMARY KEY (rut_med);
ALTER TABLE paciente     ADD CONSTRAINT paciente_pk     PRIMARY KEY (rut_pac);
ALTER TABLE receta       ADD CONSTRAINT receta_pk       PRIMARY KEY (cod_receta);
ALTER TABLE medicamento  ADD CONSTRAINT medicamento_pk  PRIMARY KEY (cod_medicamento);
ALTER TABLE dosis        ADD CONSTRAINT dosis_pk        PRIMARY KEY (id_medicamento, id_receta);
ALTER TABLE pago         ADD CONSTRAINT pago_pk         PRIMARY KEY (cod_boleta);


/* ============================================================================
   CASO 1: LLAVES FORANEAS (FOREIGN KEY)
   ============================================================================ */
ALTER TABLE medico ADD CONSTRAINT medico_especialidad_fk
    FOREIGN KEY (id_especialidad) REFERENCES especialidad (id_especialidad);

ALTER TABLE paciente ADD CONSTRAINT paciente_comuna_fk
    FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna);

ALTER TABLE receta ADD CONSTRAINT receta_digitador_fk
    FOREIGN KEY (id_digitador) REFERENCES digitador (id_digitador);

ALTER TABLE receta ADD CONSTRAINT receta_paciente_fk
    FOREIGN KEY (pac_rut) REFERENCES paciente (rut_pac);

ALTER TABLE receta ADD CONSTRAINT receta_diagnostico_fk
    FOREIGN KEY (id_diagnostico) REFERENCES diagnostico (cod_diagnostico);

ALTER TABLE receta ADD CONSTRAINT receta_medico_fk
    FOREIGN KEY (med_rut) REFERENCES medico (rut_med);

ALTER TABLE dosis ADD CONSTRAINT dosis_medicamento_fk
    FOREIGN KEY (id_medicamento) REFERENCES medicamento (cod_medicamento);

ALTER TABLE dosis ADD CONSTRAINT dosis_receta_fk
    FOREIGN KEY (id_receta) REFERENCES receta (cod_receta);

ALTER TABLE pago ADD CONSTRAINT pago_receta_fk
    FOREIGN KEY (id_receta) REFERENCES receta (cod_receta);

ALTER TABLE pago ADD CONSTRAINT pago_banco_fk
    FOREIGN KEY (id_banco) REFERENCES banco (cod_banco);


/* ============================================================================
   CASO 1: RESTRICCIONES ADICIONALES (UNIQUE y CHECK)
   ============================================================================ */

-- El telefono del medico debe ser unico en la base de datos
ALTER TABLE medico ADD CONSTRAINT medico_telefono_uk UNIQUE (telefono);

-- El digito verificador de pacientes, medicos y digitadores solo admite 0-9 y K
ALTER TABLE paciente ADD CONSTRAINT paciente_dv_ck
    CHECK (dv_pac IN ('0','1','2','3','4','5','6','7','8','9','K'));

ALTER TABLE medico ADD CONSTRAINT medico_dv_ck
    CHECK (dv_med IN ('0','1','2','3','4','5','6','7','8','9','K'));

ALTER TABLE digitador ADD CONSTRAINT digitador_dv_ck
    CHECK (dv_digitador IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- Tipos de receta permitidos
ALTER TABLE receta ADD CONSTRAINT receta_tipo_ck
    CHECK (tipo_receta IN ('DIGITAL','MAGISTRAL','RETENIDA','GENERAL','VETERINARIA'));

-- Tipos de medicamento permitidos (generico o de marca)
ALTER TABLE medicamento ADD CONSTRAINT medicamento_tipo_ck
    CHECK (tipo_medicamento IN ('GENERICO','DE MARCA'));


/* ============================================================================
   CASO 2: MODIFICACIONES POSTERIORES (ALTER TABLE)
   ============================================================================ */

-- 1) Precio unitario del medicamento, entre $1.000 y $2.000.000
ALTER TABLE medicamento ADD precio_unitario NUMBER(9);

ALTER TABLE medicamento ADD CONSTRAINT medicamento_precio_ck
    CHECK (precio_unitario BETWEEN 1000 AND 2000000);

-- 2) Metodos de pago permitidos
ALTER TABLE pago ADD CONSTRAINT pago_metodo_ck
    CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA'));

-- 3) Se elimina la columna edad y se reemplaza por fecha de nacimiento
ALTER TABLE paciente DROP COLUMN edad;

ALTER TABLE paciente ADD fecha_nacimiento DATE;

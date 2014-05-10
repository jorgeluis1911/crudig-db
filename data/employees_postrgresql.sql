
CREATE TABLE IF NOT EXISTS departments (
  dept_no char(4) NOT NULL,
  dept_name varchar(40) NOT NULL,
  PRIMARY KEY (dept_no),
  UNIQUE KEY dept_name (dept_name)
);

--
-- Volcar la base de datos para la tabla departments
--

INSERT INTO departments (dept_no, dept_name) VALUES
('', ''),
('3', 'aaaa'),
('44', 'asdasd'),
('12', 'contabilidad'),
('34', 'dfgdfg'),
('23', 'Emergencias'),
('2', 'erwerwer'),
('33', 'ffff'),
('21', 'fgdfgdfg'),
('15', 'informatica'),
('5', 'Mantenimiento'),
('50', 'probando paginacion'),
('6', 'qq'),
('14', 'qqq'),
('22', 'rrr'),
('24', 'sdasasd'),
('10', 'Sistemas'),
('11', 'sss'),
('1', 'Ventas'),
('4', 'vv'),
('16', 'vvv'),
('13', 'xxxx'),
('20', 'zzzz');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla dept_emp
--

CREATE TABLE IF NOT EXISTS dept_emp (
  emp_no int NOT NULL,
  dept_no char(4) NOT NULL,
  from_date date NOT NULL,
  to_date date NOT NULL,
  PRIMARY KEY (emp_no,dept_no)
);

--
-- Volcar la base de datos para la tabla dept_emp
--

INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date) VALUES
(123, '12', '2013-12-09', '2015-03-27'),
(123, '3', '2012-05-23', '2012-05-23'),
(123, '6', '2012-01-01', '2013-01-01'),
(234, '15', '2014-01-08', '2015-03-08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla dept_manager
--

CREATE TABLE IF NOT EXISTS dept_manager (
  dept_no char(4) NOT NULL,
  emp_no int NOT NULL,
  from_date date NOT NULL,
  to_date date NOT NULL,
  PRIMARY KEY (emp_no,dept_no)
);

--
-- Volcar la base de datos para la tabla dept_manager
--

INSERT INTO dept_manager (dept_no, emp_no, from_date, to_date) VALUES
('44', 123, '2012-01-01', '2013-01-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla employees
--

Create type sexo as enum('M','F');

CREATE TABLE IF NOT EXISTS employees (
  emp_no int NOT NULL,
  birth_date date NOT NULL,
  first_name varchar(14) NOT NULL,
  last_name varchar(16) NOT NULL,
  gender sexo NOT NULL,
  hire_date date NOT NULL,
  PRIMARY KEY (emp_no)
);

--
-- Volcar la base de datos para la tabla employees
--

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES
(123, '2000-03-26', 'jorge', 'ortega', 'M', '2014-01-08'),
(234, '2000-03-26', 'pedro', 'casas', 'M', '2014-01-08'),
(333, '2012-05-23', 'Carlos', 'Carlos', 'M', '2012-05-23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla salaries
--

CREATE TABLE IF NOT EXISTS salaries (
  emp_no int NOT NULL,
  salary int NOT NULL,
  from_date date NOT NULL,
  to_date date NOT NULL,
  PRIMARY KEY (emp_no,from_date)
);

--
-- Volcar la base de datos para la tabla salaries
--

INSERT INTO salaries (emp_no, salary, from_date, to_date) VALUES
(123, 11000, '2000-01-01', '2019-01-01'),
(234, 11000, '2000-01-01', '2019-01-01'),
(333, 111111, '2000-01-01', '2020-01-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla titles
--

CREATE TABLE IF NOT EXISTS titles (
  emp_no int NOT NULL,
  title varchar(50) NOT NULL,
  from_date date NOT NULL,
  to_date date DEFAULT NULL,
  PRIMARY KEY (emp_no,title,from_date)
);

--
-- Volcar la base de datos para la tabla titles
--


--
-- Filtros para las tablas descargadas (dump)
--

--
-- Filtros para la tabla dept_emp
--
ALTER TABLE dept_emp
  ADD CONSTRAINT dept_emp_ibfk_1 FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
  ADD CONSTRAINT dept_emp_ibfk_2 FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE;

--
-- Filtros para la tabla dept_manager
--
ALTER TABLE dept_manager
  ADD CONSTRAINT dept_manager_ibfk_1 FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
  ADD CONSTRAINT dept_manager_ibfk_2 FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE;

--
-- Filtros para la tabla salaries
--
ALTER TABLE salaries
  ADD CONSTRAINT salaries_ibfk_1 FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE;

--
-- Filtros para la tabla titles
--
ALTER TABLE titles
  ADD CONSTRAINT titles_ibfk_1 FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE;

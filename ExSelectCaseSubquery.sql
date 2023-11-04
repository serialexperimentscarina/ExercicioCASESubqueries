CREATE DATABASE projetos

USE projetos

CREATE TABLE projects(
id			INT			NOT NULL	IDENTITY(10001, 1),
name		VARCHAR(45)	NOT NULL,
description	VARCHAR(45)	NULL,
dates		DATE		NOT NULL	CHECK(dates > '2014-09-01')
PRIMARY KEY(id)
)

CREATE TABLE users(
id			INT			NOT NULL	IDENTITY(1, 1),
name		VARCHAR(45)	NOT NULL,
username	VARCHAR(45)	NOT NULL	UNIQUE,
password	VARCHAR(45)	NOT NULL	DEFAULT '123mudar',
email		VARCHAR(45)	NOT NULL
PRIMARY KEY(id)
)

CREATE TABLE user_has_projects(
users_id	INT			NOT NULL,
projects_id	INT			NOT NULL,
PRIMARY KEY(users_id, projects_id),
FOREIGN KEY(users_id) REFERENCES users(id),
FOREIGN KEY(projects_id) REFERENCES projects(id)
)

--Removendo 'UNIQUE' constraint de username
ALTER TABLE users
DROP CONSTRAINT UQ__users__F3DBC572C2423FF5;

--Alterando coluna
ALTER TABLE users
ALTER COLUMN username VARCHAR(10) NOT NULL

--Recriando constraint
ALTER TABLE users
ADD UNIQUE (username);

ALTER TABLE users
ALTER COLUMN password VARCHAR(8) NOT NULL

INSERT INTO users(name, username, email) VALUES(
'Maria', 'Rh_maria', 'maria@empresa.com')

INSERT INTO users VALUES(
'Paulo', 'Ti_paulo', '123@456', 'paulo@empresa.com')

INSERT INTO users(name, username, email) VALUES
('Ana', 'Rh_ana', 'ana@empresa.com'),
('Clara', 'Ti_clara', 'clara@empresa.com')

INSERT INTO users VALUES(
'Aparecido', 'Rh_apareci', '55@!cido', 'aparecido@empresa.com')

INSERT INTO projects VALUES
('Re-folha', 'Refatoração das Folhas', '2014-09-05'),
('Manutenção PCs', 'Manutenção PCs', '2014-09-06'),
('Auditoria', NULL, '2014-09-07')

INSERT INTO user_has_projects VALUES
(1, 10001),
(5, 10001),
(3, 10003),
(4, 10002),
(2, 10002)

UPDATE projects
SET dates = '2014-09-12'
WHERE name = 'Manutenção PCs'

UPDATE users
SET username = 'Rh_cido'
WHERE name = 'Aparecido'

UPDATE users
SET username = '888@*,'
WHERE username = 'Rh_maria' AND password='123mudar'

DELETE user_has_projects
WHERE users_id = 2 AND projects_id = 10002

-- Fazer uma consulta que retorne id, nome, email, username e caso a senha seja diferente de
-- 123mudar, mostrar ******** (8 asteriscos), caso contrário, mostrar a própria senha.
SELECT id, name AS nome, email, username,
	CASE WHEN (password = '123mudar')
	THEN
		password
	ELSE
		'********'
	END AS senha
FROM users

-- Considerando que o projeto 10001 durou 15 dias, fazer uma consulta que mostre o nome do
--projeto, descrição, data, data_final do projeto realizado por usuário de e-mail
--aparecido@empresa.com
SELECT name AS nome, description AS descrição, 
	CONVERT(CHAR(10), dates, 103) AS data,
	CASE WHEN (id = 10001)
	THEN
		CONVERT(CHAR(10), DATEADD(DAY, 15, dates),103)
	END AS data_final
FROM projects
WHERE id IN 
(
	SELECT projects_id
	FROM user_has_projects
	WHERE users_id IN
		(
			SELECT id
			FROM users
			WHERE email = 'aparecido@empresa.com'
		)
)

-- Fazer uma consulta que retorne o nome e o email dos usuários que estão envolvidos no
--projeto de nome Auditoria
SELECT name AS nome, email
FROM users
WHERE id IN 
(
	SELECT users_id
	FROM user_has_projects
	WHERE projects_id IN
		(
			SELECT id
			FROM projects
			WHERE name = 'Auditoria'
		)
)

-- Considerando que o custo diário do projeto, cujo nome tem o termo Manutenção, é de 79.85
--e ele deve finalizar 16/09/2014, consultar, nome, descrição, data, data_final e custo_total do
--projeto
SELECT name AS nome, description AS descrição, 
	CONVERT(CHAR(10), dates, 103) AS data,
	'16/09/2014' AS data_final,
	'R$ ' + CAST((DATEDIFF(DAY, dates, '2014-09-16') * 79.85) AS VARCHAR(7)) AS custo_total
FROM projects
WHERE name LIKE '%Manutenção%'
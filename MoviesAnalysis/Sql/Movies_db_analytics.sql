-- Create tables

-- Movies table 

USE [movies]
GO

IF OBJECT_ID('mov_db') IS NOT NULL 
	DROP TABLE mov_db;
GO

CREATE TABLE mov_db(
	 id VARCHAR(50) NOT NULL,
	 tagline VARCHAR(MAX),
	 genres VARCHAR(100),
	 original_language VARCHAR(50),
	 production_companies VARCHAR(MAX),
	 production_countries VARCHAR(150),
	 popularity FLOAT,
	 runtime FLOAT,
	 overview VARCHAR(MAX),
	 spoken_languages VARCHAR(250),
	 poster_path VARCHAR(MAX),
	 cast VARCHAR(MAX),
	 cast_size INT,
	 crew_size INT,
	 director VARCHAR(150)
);
GO

-- Countries table 

USE [movies]
GO

IF OBJECT_ID('countries_table') IS NOT NULL 
	DROP TABLE countries;
GO

CREATE TABLE countries_table(
	country VARCHAR(250),
	code_2 VARCHAR(20),
	code_3 VARCHAR(30),
	country_code INT,
	iso_3166_2 VARCHAR(100),
	continent VARCHAR(20),
	sub_region VARCHAR(50),
);
GO

-- Votes Table

USE [movies]
GO

IF OBJECT_ID('Votes_table') IS NOT NULL 
	DROP TABLE countries;
GO

CREATE TABLE Votes_table(
	id INT NOT NULL, 
	vote_count FLOAT, 
	vote_average FLOAT
);
GO

-- Dates Table

USE [movies]
GO

IF OBJECT_ID('movies_date_name') IS NOT NULL 
	DROP TABLE countries;
GO

CREATE TABLE movies_date_name(
	id INT, 
	title VARCHAR(250), 
	revenue FLOAT, 
	budget FLOAT, 
	release_date DATETIME
);
GO

select * from Movies
-- Add constraints
-- pk mov_db

ALTER TABLE [dbo].[Votes_table]
ADD CONSTRAINT pk_id_votes PRIMARY KEY ([id])
GO

-- pk countries_table 

ALTER TABLE [dbo].[countries_table]
ALTER COLUMN [country] VARCHAR(250) NOT NULL;
GO

ALTER TABLE [dbo].[countries_table]
ADD CONSTRAINT pk_id_countr PRIMARY KEY ([country])
GO

-- SQL Data Exploration
/*

Querys used for Tableau Project

*/
-- Number of films by years

CREATE VIEW films_year
AS
	SELECT 
		YEAR(release_date) AS 'Year', 
		COUNT(YEAR(release_date)) AS 'Total',
		SUM(revenue) AS 'Revenue by year',
		SUM(budget) AS 'Budget by year'
	FROM 
		[dbo].[movies_date_name]
	WHERE
		YEAR(release_date) > 1989
	GROUP BY
		YEAR(release_date)
GO

SELECT * FROM films_year
ORDER BY Year

-- The Most raised films

CREATE VIEW  Films_By_Revenue
AS
	SELECT 
		title,
		revenue
	FROM 
		[dbo].[movies_date_name]
GO

-- The most raised genres

CREATE VIEW Total_genres
AS
SELECT 
	genres,
	COUNT(genres) AS 'Total_Genres'
FROM 
	[dbo].[mov_db]
GROUP BY
	genres
GO

SELECT * FROM Total_genres
ORDER BY Total_Genres DESC
GO

-- Countries Total Films and revenues

SELECT 
	[D].[revenue],
	[M].[production_countries]
FROM 
	[dbo].[movies_date_name] AS [D]
JOIN
	[dbo].[mov_db] AS [M]
ON
	[D].[id] = [M].[id]


SELECT 
	SUM([D].[revenue]) AS 'Revenue',
	[M].[production_countries],
	COUNT([D].[title]) AS 'Total_Titles'
FROM 
	[dbo].[movies_date_name] AS [D]
JOIN
	[dbo].[mov_db] AS [M]
ON
	[D].[id] = [M].[id]
WHERE
	[M].[production_countries] <> 'Unknow'
GROUP BY 
	[M].[production_countries]
ORDER BY 
	Total_Titles DESC


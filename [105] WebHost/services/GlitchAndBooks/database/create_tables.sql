CREATE TABLE Users (
   userId SERIAL PRIMARY KEY,
   username VARCHAR(55) UNIQUE,
   password VARCHAR(55) NOT NULL,
   email VARCHAR(55) UNIQUE NOT NULL,
   avatar BYTEA,
);

CREATE TABLE Authors (
   authorId SERIAL PRIMARY KEY,
   firstname VARCHAR(155),
   lastname VARCHAR(155) NOT NULL
);

CREATE TABLE Languages (
   languagesId SERIAL PRIMARY KEY,
   language VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Genres (
   genresId SERIAL PRIMARY KEY,
   name VARCHAR(50) NOT NULL
);

CREATE TABLE Types (
   typesId SERIAL PRIMARY KEY,
   name VARCHAR(50) NOT NULL
);

CREATE TABLE Country_origin (
   countryOriginId SERIAL PRIMARY KEY,
   country VARCHAR(50) NOT NULL
   code VARCHAR(50) NOT NULL
);

CREATE TABLE Wishlist (
   wishlistId SERIAL PRIMARY KEY,
   title VARCHAR(50) NOT NULL,
   author VARCHAR(155) NOT NULL,
   price MONEY,
   userId INT NOT NULL REFERENCES Users(userId)
);

CREATE TABLE Books (
   bookId SERIAL PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   page_number SMALLINT,
   height INT,
   width INT,
   read BOOLEAN NOT NULL,
   publication_date DATE,
   want_to_read BOOLEAN NOT NULL,
   notes TEXT,
   physical BOOLEAN NOT NULL,
   countryOriginId INT NOT NULL REFERENCES Country_origin(countryOriginId),
   typesId INT NOT NULL REFERENCES Types(typesId),
   languagesId INT NOT NULL REFERENCES Languages(languagesId),
   userId INT NOT NULL REFERENCES Users(userId)
);

CREATE TABLE written_by (
   bookId INT REFERENCES Books(bookId),
   authorId INT REFERENCES Authors(authorId),
   PRIMARY KEY(bookId, authorId)
);

CREATE TABLE has_genres (
   bookId INT REFERENCES Books(bookId),
   genresId INT REFERENCES Genres(genresId),
   PRIMARY KEY(bookId, genresId)
);

INSERT VALUES INTO Country_origin (country, code) VALUES ('France', 'FR');
INSERT VALUES INTO Country_origin (country, code) VALUES ('UK', 'UK');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Russia', 'RUS');
INSERT VALUES INTO Country_origin (country, code) VALUES ('USA', 'USA');
INSERT VALUES INTO Country_origin (country, code) VALUES ('China', 'CHN');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Japan', 'JPN');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Iceland', 'ISL');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Italy', 'ITA');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Canada', 'CAN');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Portugal', 'PRT');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Germany', 'GER');
INSERT VALUES INTO Country_origin (country, code) VALUES ('Other', 'NTM');

INSERT VALUES INTO Types (name) VALUES ('Fiction');
INSERT VALUES INTO Types (name) VALUES ('Non-fiction');
INSERT VALUES INTO Types (name) VALUES ('Poetry');
INSERT VALUES INTO Types (name) VALUES ('Theatre');
INSERT VALUES INTO Types (name) VALUES ('Illustrated-Book');
INSERT VALUES INTO Types (name) VALUES ('Comics');
INSERT VALUES INTO Types (name) VALUES ('Manga');
INSERT VALUES INTO Types (name) VALUES ('Essay');
INSERT VALUES INTO Types (name) VALUES ('Magazine');

INSERT VALUES INTO Languages (language) VALUES ('French');
INSERT VALUES INTO Languages (language) VALUES ('English');
INSERT VALUES INTO Languages (language) VALUES ('Japanese');
INSERT VALUES INTO Languages (language) VALUES ('German');
INSERT VALUES INTO Languages (language) VALUES ('Spanish');
INSERT VALUES INTO Languages (language) VALUES ('Other');

INSERT VALUES INTO Genres (name) VALUES ('Fantasy');
INSERT VALUES INTO Genres (name) VALUES ('Science-Fiction');
INSERT VALUES INTO Genres (name) VALUES ('Young-Adult');
INSERT VALUES INTO Genres (name) VALUES ('Historical');
INSERT VALUES INTO Genres (name) VALUES ('Biography');
INSERT VALUES INTO Genres (name) VALUES ('Romance');
INSERT VALUES INTO Genres (name) VALUES ('Contemporary');
INSERT VALUES INTO Genres (name) VALUES ('Crime');
INSERT VALUES INTO Genres (name) VALUES ('Recipes');
INSERT VALUES INTO Genres (name) VALUES ('Others');
INSERT VALUES INTO Genres (name) VALUES ('Classic');
INSERT VALUES INTO Genres (name) VALUES ('Philosophy');
INSERT VALUES INTO Genres (name) VALUES ('Humour');
INSERT VALUES INTO Genres (name) VALUES ('Selft Development');
INSERT VALUES INTO Genres (name) VALUES ('Literature');

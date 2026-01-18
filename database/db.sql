
DROP DATABASE IF EXISTS cinema_db;
CREATE DATABASE cinema_db;

\c cinema_db;

-- Table: Film
CREATE TABLE Film (
    FilmID SERIAL PRIMARY KEY,
    Titre VARCHAR(200) NOT NULL,
    Duree INTEGER,
    Genre VARCHAR(100),
    Description TEXT,
    DateSortie DATE,
    AfficheURL VARCHAR(500),
    RealisateurNom VARCHAR(200),
    Langue VARCHAR(50),
    SousTitle VARCHAR(50)
);

-- Table: Salle
CREATE TABLE Salle (
    SalleID SERIAL PRIMARY KEY,
    Nom VARCHAR(100) NOT NULL,
    NombreRangees INTEGER,
    SiegesParRangee INTEGER,
    CapaciteTotal INTEGER
);

-- Table: TypePlace
CREATE TABLE TypePlace (
    TypePlaceID SERIAL PRIMARY KEY,
    Nom VARCHAR(50) NOT NULL,
    Description TEXT,
    Couleur VARCHAR(20)
);

-- Table: TypeClient
CREATE TABLE TypeClient (
    TypeClientID SERIAL PRIMARY KEY,
    Nom VARCHAR(50) NOT NULL,
    Description TEXT,
    AgeMin INTEGER,
    AgeMax INTEGER
);

-- Table: Siege
CREATE TABLE Siege (
    SiegeID SERIAL PRIMARY KEY,
    SalleID INTEGER NOT NULL REFERENCES Salle(SalleID),
    TypePlaceID INTEGER NOT NULL REFERENCES TypePlace(TypePlaceID),
    Rangee INTEGER NOT NULL,
    Numero INTEGER NOT NULL,
    NumeroComplet VARCHAR(10),
    EstAccessiblePMR BOOLEAN DEFAULT FALSE,
    Actif BOOLEAN DEFAULT TRUE
);

-- Table: Seance
CREATE TABLE Seance (
    SeanceID SERIAL PRIMARY KEY,
    FilmID INTEGER NOT NULL REFERENCES Film(FilmID),
    SalleID INTEGER NOT NULL REFERENCES Salle(SalleID),
    DateHeure TIMESTAMP NOT NULL,
    Langue VARCHAR(50),
    Format VARCHAR(50)
);

-- Table: PrixBase
CREATE TABLE PrixBase (
    PrixBaseID SERIAL PRIMARY KEY,
    TypePlaceID INTEGER NOT NULL REFERENCES TypePlace(TypePlaceID),
    Prix DECIMAL(10, 2) NOT NULL,
    DateDebut DATE,
    DateFin DATE
);

-- Table: Remise
CREATE TABLE Remise (
    RemiseID SERIAL PRIMARY KEY,
    TypePlaceID INTEGER REFERENCES TypePlace(TypePlaceID),
    TypeClientID INTEGER REFERENCES TypeClient(TypeClientID),
    PourcentageRemise DECIMAL(5, 2),
    DateDebut DATE,
    DateFin DATE
);

-- Table: Role
CREATE TABLE Role (
    RoleID SERIAL PRIMARY KEY,
    NomRole VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT
);

-- Table: Utilisateur
CREATE TABLE Utilisateur (
    UtilisateurID SERIAL PRIMARY KEY,
    Nom VARCHAR(100) NOT NULL,
    Prenom VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    MotDePasse VARCHAR(255) NOT NULL,
    Telephone VARCHAR(20),
    DateNaissance DATE,
    TypeClientID INTEGER REFERENCES TypeClient(TypeClientID),
    DateInscription TIMESTAMP,
    DerniereConnexion TIMESTAMP,
    Actif BOOLEAN DEFAULT TRUE
);

-- Table: UtilisateurRole
CREATE TABLE UtilisateurRole (
    UtilisateurID INTEGER REFERENCES Utilisateur(UtilisateurID) ON DELETE CASCADE,
    RoleID INTEGER REFERENCES Role(RoleID) ON DELETE CASCADE,
    PRIMARY KEY (UtilisateurID, RoleID)
);

-- Table: Reservation
CREATE TABLE Reservation (
    ReservationID SERIAL PRIMARY KEY,
    UtilisateurID INTEGER NOT NULL REFERENCES Utilisateur(UtilisateurID),
    SeanceID INTEGER NOT NULL REFERENCES Seance(SeanceID),
    MontantTotal DECIMAL(10, 2),
    StatutReservation VARCHAR(20),
    DateReservation TIMESTAMP,
    DateExpiration TIMESTAMP
);

-- Table: SeanceSiegeReserve
CREATE TABLE SeanceSiegeReserve (
    ReservationSiegeID SERIAL PRIMARY KEY,
    SeanceID INTEGER NOT NULL REFERENCES Seance(SeanceID),
    SiegeID INTEGER NOT NULL REFERENCES Siege(SiegeID),
    ReservationID INTEGER REFERENCES Reservation(ReservationID),
    TypeClientID INTEGER REFERENCES TypeClient(TypeClientID),
    PrixPaye DECIMAL(10, 2),
    DateReservation TIMESTAMP
);

-- Table: ModePaiement
CREATE TABLE ModePaiement (
    ModePaiementID SERIAL PRIMARY KEY,
    Nom VARCHAR(50) NOT NULL,
    Description TEXT,
    Actif BOOLEAN DEFAULT TRUE
);

-- Table: Paiement
CREATE TABLE Paiement (
    PaiementID SERIAL PRIMARY KEY,
    ReservationID INTEGER NOT NULL REFERENCES Reservation(ReservationID),
    UtilisateurID INTEGER NOT NULL REFERENCES Utilisateur(UtilisateurID),
    Montant DECIMAL(10, 2) NOT NULL,
    ModePaiementID INTEGER NOT NULL REFERENCES ModePaiement(ModePaiementID),
    StatutPaiement VARCHAR(20),
    DatePaiement TIMESTAMP,
    ReferenceTransaction VARCHAR(255)
);

-- Table: Billet
CREATE TABLE Billet (
    BilletID SERIAL PRIMARY KEY,
    ReservationID INTEGER NOT NULL REFERENCES Reservation(ReservationID),
    SiegeID INTEGER NOT NULL REFERENCES Siege(SiegeID),
    CodeBillet VARCHAR(50) UNIQUE,
    Utilise BOOLEAN DEFAULT FALSE,
    DateUtilisation TIMESTAMP,
    DateCreation TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_seance_dateheure ON Seance(DateHeure);
CREATE INDEX idx_utilisateur_email ON Utilisateur(Email);
CREATE INDEX idx_reservation_utilisateur ON Reservation(UtilisateurID);
CREATE INDEX idx_seance_film ON Seance(FilmID);

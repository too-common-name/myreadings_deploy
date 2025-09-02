\c users_db

CREATE TABLE users (
    keycloak_user_id UUID PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    theme_preference VARCHAR,
    genre_preference TEXT[]
);
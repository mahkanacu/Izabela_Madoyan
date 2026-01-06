drop schema if exists movies_schema cascade;
create schema if not exists movies_schema;
set search_path to movies_schema;

-- 1. Genres table
create table genres (
    genre_id int primary key,
    genre_name varchar(100) not null
);

-- 2. People table 
create table people (
    person_id int primary key,
    name varchar(255) not null,
    birth_date date,
    biography text
);

-- 3. Movies table 
create table movies (
    movie_id int,
    title text not null,
    release_date date not null,
    runtime int,
    budget bigint,
    revenue bigint,
	overview text,
    original_language varchar(10),
    popularity numeric,
    primary key (movie_id, release_date)
) partition by range (release_date);

-- 4. ՍՏԵՂԾԵԼ partition-ՆԵՐԸ
create table movies_classic partition of movies for values from('1900-01-01') to ('2000-01-01');
create table movies_modern partition of movies for values from ('2000-01-01') to ('2030-01-01');

-- 5. Movie_Genres table
create table movie_genres (
    movie_id int,
    release_date date,
    genre_id int references genres(genre_id),
    foreign key (movie_id, release_date) references movies(movie_id, release_date)
);

-- 6. Movie_Cast table
create table movie_cast (
    cast_id serial primary key,
    movie_id int,
    release_date date,
    person_id int references people(person_id),
    character_name varchar(255),
    cast_order int,
    role varchar(50),
    foreign key (movie_id, release_date) references movies(movie_id, release_date)
);



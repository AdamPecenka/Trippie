create table users(
    id serial primary key,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    email varchar(320) unique not null,
    phone_number varchar(20) unique not null,
    password text not null
)
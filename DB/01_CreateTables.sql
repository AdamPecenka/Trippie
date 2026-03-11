create type trip_role as
    enum('TRIP_MEMBER', 'TRIP_MANAGER');

create table users(
    id uuid primary key,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    email varchar(320) unique not null,
    phone_number varchar(20) unique not null,
    password text not null,
    role trip_role default 'TRIP_MEMBER',
    created_at timestamptz default current_timestamp,
    updated_at timestamptz default current_timestamp
);

create table refresh_tokens(
    id uuid primary key,
    user_id uuid references users not null,
    token_value text not null,
    expires_at timestamptz not null,
    revoked boolean not null,
    created_at timestamptz default current_timestamp,
    updated_at timestamptz default current_timestamp
)


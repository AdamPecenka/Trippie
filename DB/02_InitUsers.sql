insert into users(id, firstname, lastname, email, phone_number, password)
values
    (gen_random_uuid(), 'John', 'Doe', 'john.doe@gmail.com', '+4210900111222', 'Heslo@123'),
    (gen_random_uuid(), 'Janko', 'Hrasko', 'janko.hrasko@gmail.com', '+4210900333444', 'Heslo@123')
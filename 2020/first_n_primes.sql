CREATE DATABASE primos;
use primos;

create table primos
(
    num int
);

drop procedure n_first_primes;
DELIMITER $$
create procedure n_first_primes(
    lim int
)
BEGIN
     declare num int default 1;
    declare a int default 1;
    while num <= lim
        do
            iteratorLoop:
            while a <= num
                do

                    if (a = num) then
                        insert into primos (num) values (num);
                    elseif (mod(num, a) = 0) then
                        leave iteratorLoop;
                    end if;

                    set a = a + 1;
                end while;
            set a = 2;
            set num = num + 1;
        end while;

    COMMIT;
END $$
DELIMITER ;
